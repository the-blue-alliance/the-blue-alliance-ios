import Photos
import TBAAPI
import UIKit

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {
    func mediaSelected(image: UIImage?, directURL: URL?, viewURL: URL?)
}

enum MediaSection: Hashable {
    case videos
    case images
}

enum TeamMediaItem: Hashable {
    case image(Photo)
    case video(Video)

    struct Photo: Hashable {
        let foreignKey: String
        let type: String
        let directURL: URL?
        let viewURL: URL?

        var isInstagram: Bool { type == "instagram-image" }
    }

    struct Video: Hashable {
        let youtubeKey: String
        let viewURL: URL?
    }
}

class TeamMediaCollectionViewController: TBACollectionViewController {

    private static let spacerSize: CGFloat = 3.0
    private static let imageTypes: Set<String> = [
        "imgur", "instagram-image",
    ]
    private static let videoTypes: Set<String> = ["youtube"]

    private let teamKey: String
    private let pasteboard: UIPasteboard
    private let photoLibrary: PHPhotoLibrary

    var year: Int? {
        didSet {
            if oldValue != year {
                applyMedia([])
                refresh()
            }
        }
    }

    weak var delegate: TeamMediaCollectionViewControllerDelegate?

    private var dataSource: CollectionViewDataSource<MediaSection, TeamMediaItem>!
    private var media: [TeamMediaItem] = []
    private var imageCache: [String: UIImage] = [:]
    private var imageErrors: [String: Error] = [:]
    private var downloadTasks: [String: Task<Void, Never>] = [:]

    // MARK: Init

    init(
        teamKey: String,
        year: Int? = nil,
        pasteboard: UIPasteboard = .general,
        photoLibrary: PHPhotoLibrary = .shared(),
        dependencies: Dependencies
    ) {
        self.teamKey = teamKey
        self.year = year
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary

        super.init(
            collectionViewLayout: UICollectionViewCompositionalLayout { _, _ in nil },
            dependencies: dependencies
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self else { return nil }
            let section = self.dataSource?.sectionIdentifier(for: sectionIndex) ?? .images
            switch section {
            case .videos:
                return Self.makeVideoSection(env: env)
            case .images:
                return Self.makeImageSection(env: env)
            }
        }
    }

    private static func makeImageSection(env: NSCollectionLayoutEnvironment)
        -> NSCollectionLayoutSection
    {
        let columns = env.traitCollection.horizontalSizeClass == .regular ? 3 : 2
        let spacer = TeamMediaCollectionViewController.spacerSize
        let containerWidth = env.container.effectiveContentSize.width
        let itemWidth =
            (containerWidth - spacer * CGFloat(columns - 1) - 2 * spacer) / CGFloat(columns)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemWidth)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemWidth)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: columns
        )
        group.interItemSpacing = .fixed(spacer)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacer
        section.contentInsets = NSDirectionalEdgeInsets(
            top: spacer,
            leading: spacer,
            bottom: spacer,
            trailing: spacer
        )
        return section
    }

    private static func makeVideoSection(env: NSCollectionLayoutEnvironment)
        -> NSCollectionLayoutSection
    {
        let spacer = TeamMediaCollectionViewController.spacerSize
        let containerWidth = env.container.effectiveContentSize.width
        let itemWidth = containerWidth - 2 * spacer
        let itemHeight = itemWidth * (9.0 / 16.0)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacer
        section.contentInsets = NSDirectionalEdgeInsets(
            top: spacer,
            leading: spacer,
            bottom: spacer,
            trailing: spacer
        )
        return section
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(MediaCollectionViewCell.self)
        collectionView.registerReusableCell(PlayerCollectionViewCell.self)

        setupDataSource()
        collectionView.dataSource = dataSource
        collectionView.setCollectionViewLayout(makeLayout(), animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        downloadTasks.values.forEach { $0.cancel() }
        downloadTasks.removeAll()
    }

    // MARK: UICollectionView Delegate

    override func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .image(let photo):
            if photo.isInstagram {
                if let viewURL = photo.viewURL, urlOpener.canOpenURL(viewURL) {
                    urlOpener.open(viewURL, options: [:], completionHandler: nil)
                }
            } else {
                delegate?.mediaSelected(
                    image: imageCache[photo.foreignKey],
                    directURL: photo.directURL,
                    viewURL: photo.viewURL
                )
            }
        case .video:
            // The embedded YouTube player handles its own play/pause taps.
            break
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        switch item {
        case .image(let photo):
            return imageContextMenu(for: photo)
        case .video(let video):
            return videoContextMenu(for: video)
        }
    }

    private func imageContextMenu(for photo: TeamMediaItem.Photo) -> UIContextMenuConfiguration? {
        let cachedImage = imageCache[photo.foreignKey]
        var actions: [UIMenuElement] = []

        if !photo.isInstagram {
            actions.append(
                UIAction(title: "View", image: UIImage(systemName: "eye.fill")) { _ in
                    self.delegate?.mediaSelected(
                        image: cachedImage,
                        directURL: photo.directURL,
                        viewURL: photo.viewURL
                    )
                }
            )
        }

        if let viewURL = photo.viewURL, urlOpener.canOpenURL(viewURL) {
            actions.append(
                UIAction(title: "View Online", image: UIImage(systemName: "safari.fill")) { _ in
                    self.urlOpener.open(viewURL, options: [:], completionHandler: nil)
                }
            )
        }

        if let image = cachedImage {
            actions.append(
                UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc.fill")) { _ in
                    self.pasteboard.image = image
                }
            )
            actions.append(
                UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down.fill")) {
                    _ in
                    self.photoLibrary.performChanges(
                        {
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        },
                        completionHandler: nil
                    )
                }
            )
        }

        guard !actions.isEmpty else { return nil }
        return UIContextMenuConfiguration(
            identifier: photo.foreignKey as NSString,
            previewProvider: nil
        ) { _ in
            UIMenu(title: "", children: actions)
        }
    }

    private func videoContextMenu(for video: TeamMediaItem.Video) -> UIContextMenuConfiguration? {
        guard let viewURL = video.viewURL, urlOpener.canOpenURL(viewURL) else { return nil }
        return UIContextMenuConfiguration(
            identifier: video.youtubeKey as NSString,
            previewProvider: nil
        ) { _ in
            let viewOnYouTubeAction = UIAction(
                title: "View on YouTube",
                image: UIImage(systemName: "safari.fill")
            ) { _ in
                self.urlOpener.open(viewURL, options: [:], completionHandler: nil)
            }
            return UIMenu(title: "", children: [viewOnYouTubeAction])
        }
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard let foreignKey = configuration.identifier as? String,
            let item = media.first(where: { $0.contextMenuIdentifier == foreignKey })
        else { return }
        switch item {
        case .image(let photo):
            delegate?.mediaSelected(
                image: imageCache[photo.foreignKey],
                directURL: photo.directURL,
                viewURL: photo.viewURL
            )
        case .video(let video):
            if let viewURL = video.viewURL, urlOpener.canOpenURL(viewURL) {
                urlOpener.open(viewURL, options: [:], completionHandler: nil)
            }
        }
    }

    // MARK: Data Source

    private func setupDataSource() {
        dataSource = CollectionViewDataSource<MediaSection, TeamMediaItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .image(let photo):
                let cell: MediaCollectionViewCell = collectionView.dequeueReusableCell(
                    indexPath: indexPath
                )
                if photo.isInstagram {
                    cell.state = .error("Instagram image")
                } else if let image = self.imageCache[photo.foreignKey] {
                    cell.state = .loaded(image)
                } else if self.imageErrors[photo.foreignKey] != nil {
                    cell.state = .error("Image unavailable")
                } else {
                    cell.state = .loading
                }
                return cell
            case .video(let video):
                let cell: PlayerCollectionViewCell = collectionView.dequeueReusableCell(
                    indexPath: indexPath
                )
                cell.configure(youtubeKey: video.youtubeKey)
                return cell
            }
        }
        dataSource.delegate = self
    }

    private func applyMedia(_ items: [TeamMediaItem]) {
        self.media = items
        var snapshot = NSDiffableDataSourceSnapshot<MediaSection, TeamMediaItem>()

        let videos = items.compactMap { item -> TeamMediaItem? in
            if case .video = item { return item } else { return nil }
        }
        let images = items.compactMap { item -> TeamMediaItem? in
            if case .image = item { return item } else { return nil }
        }

        if !images.isEmpty {
            snapshot.appendSections([.images])
            snapshot.appendItems(images, toSection: .images)
        }
        if !videos.isEmpty {
            snapshot.appendSections([.videos])
            snapshot.appendItems(videos, toSection: .videos)
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

}

extension TeamMediaCollectionViewController: Refreshable {

    var isDataSourceEmpty: Bool {
        return media.isEmpty
    }

    func refresh() {
        guard let year = year else { return }
        runRefresh { [weak self] in
            guard let self else { return }
            let apiMedia = try await self.dependencies.api.teamMediaByYear(
                teamKey: self.teamKey,
                year: year
            )
            let items: [TeamMediaItem] = apiMedia.compactMap { Self.makeItem(from: $0) }
            self.imageErrors.removeAll()
            self.applyMedia(items)
            for item in items {
                if case .image(let photo) = item, !photo.isInstagram {
                    self.downloadImage(for: photo)
                }
            }
        }
    }

    private static func makeItem(from media: Media) -> TeamMediaItem? {
        let type = media._type.rawValue
        if Self.imageTypes.contains(type) {
            return .image(
                .init(
                    foreignKey: media.foreignKey,
                    type: type,
                    directURL: media.directUrl.flatMap { URL(string: $0) },
                    viewURL: media.viewUrl.flatMap { URL(string: $0) }
                )
            )
        }
        if Self.videoTypes.contains(type), !media.foreignKey.isEmpty {
            return .video(
                .init(
                    youtubeKey: media.foreignKey,
                    viewURL: media.viewUrl.flatMap { URL(string: $0) }
                )
            )
        }
        return nil
    }

    private func downloadImage(for photo: TeamMediaItem.Photo) {
        guard imageCache[photo.foreignKey] == nil else { return }
        guard let url = photo.directURL else { return }
        downloadTasks[photo.foreignKey]?.cancel()
        downloadTasks[photo.foreignKey] = Task { @MainActor [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self?.imageCache[photo.foreignKey] = image
                } else {
                    self?.imageErrors[photo.foreignKey] = URLError(.cannotDecodeContentData)
                }
                self?.reconfigure(photo: photo)
            } catch {
                if !Task.isCancelled {
                    self?.imageErrors[photo.foreignKey] = error
                    self?.reconfigure(photo: photo)
                }
            }
        }
    }

    private func reconfigure(photo: TeamMediaItem.Photo) {
        let item = TeamMediaItem.image(photo)
        var snapshot = dataSource.snapshot()
        if snapshot.itemIdentifiers.contains(item) {
            snapshot.reconfigureItems([item])
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }

}

extension TeamMediaCollectionViewController: Stateful {

    var noDataText: String? {
        return "No media for team"
    }

}

private extension TeamMediaItem {
    var contextMenuIdentifier: String {
        switch self {
        case .image(let photo): return photo.foreignKey
        case .video(let video): return video.youtubeKey
        }
    }
}
