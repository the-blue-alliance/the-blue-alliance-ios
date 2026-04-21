import Photos
import TBAAPI
import UIKit

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {
    func mediaSelected(image: UIImage?, directURL: URL?)
}

struct TeamMediaItem: Hashable {
    let foreignKey: String
    let type: String
    let directURL: URL?
    let viewURL: URL?
}

class TeamMediaCollectionViewController: TBACollectionViewController {

    private static let spacerSize: CGFloat = 3.0
    private static let imageTypes: Set<String> = [
        "imgur", "cdphotothread", "avatar", "instagram-image",
    ]

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

    private var dataSource: CollectionViewDataSource<String, TeamMediaItem>!
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

        super.init(collectionViewLayout: Self.makeLayout(), dependencies: dependencies)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private static func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, env in
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
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
        collectionView.dataSource = dataSource
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
        delegate?.mediaSelected(image: imageCache[item.foreignKey], directURL: item.directURL)
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let cachedImage = imageCache[item.foreignKey]
        let configuration = UIContextMenuConfiguration(
            identifier: item.foreignKey as NSString,
            previewProvider: nil
        ) {
            _ in
            let viewAction = UIAction(title: "View", image: UIImage(systemName: "eye.fill")) { _ in
                self.delegate?.mediaSelected(image: cachedImage, directURL: item.directURL)
            }
            var actions: [UIMenuElement] = [viewAction]

            if let viewURL = item.viewURL, self.urlOpener.canOpenURL(viewURL) {
                let viewOnlineAction = UIAction(
                    title: "View Online",
                    image: UIImage(systemName: "safari.fill")
                ) { _ in
                    self.urlOpener.open(viewURL, options: [:], completionHandler: nil)
                }
                actions.append(viewOnlineAction)
            }

            if let image = cachedImage {
                let copyAction = UIAction(
                    title: "Copy",
                    image: UIImage(systemName: "doc.on.doc.fill")
                ) { _ in
                    self.pasteboard.image = image
                }
                actions.append(copyAction)

                let saveAction = UIAction(
                    title: "Save",
                    image: UIImage(systemName: "square.and.arrow.down.fill")
                ) {
                    _ in
                    self.photoLibrary.performChanges(
                        {
                            PHAssetChangeRequest.creationRequestForAsset(from: image)
                        },
                        completionHandler: nil
                    )
                }
                actions.append(saveAction)
            }
            return UIMenu(title: "", children: actions)
        }
        return configuration
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard let foreignKey = configuration.identifier as? String,
            let item = media.first(where: { $0.foreignKey == foreignKey })
        else { return }
        delegate?.mediaSelected(image: imageCache[foreignKey], directURL: item.directURL)
    }

    // MARK: Data Source

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<
            MediaCollectionViewCell, TeamMediaItem
        > {
            [weak self] cell, _, item in
            guard let self else { return }
            if let image = self.imageCache[item.foreignKey] {
                cell.state = .loaded(image)
            } else if let error = self.imageErrors[item.foreignKey] {
                cell.state = .error("Error loading media - \(error.localizedDescription)")
            } else {
                cell.state = .loading
            }
            cell.accessibilityIdentifier = "media.\(item.foreignKey)"
        }
        dataSource = CollectionViewDataSource<String, TeamMediaItem>(collectionView: collectionView)
        {
            collectionView,
            indexPath,
            item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
        dataSource.delegate = self
    }

    private func applyMedia(_ items: [TeamMediaItem]) {
        self.media = items
        var snapshot = NSDiffableDataSourceSnapshot<String, TeamMediaItem>()
        if !items.isEmpty {
            snapshot.appendSections([""])
            snapshot.appendItems(items, toSection: "")
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
            let items: [TeamMediaItem] =
                apiMedia
                .filter { Self.imageTypes.contains($0._type.rawValue) }
                .map { m in
                    TeamMediaItem(
                        foreignKey: m.foreignKey,
                        type: m._type.rawValue,
                        directURL: m.directUrl.flatMap { URL(string: $0) },
                        viewURL: m.viewUrl.flatMap { URL(string: $0) }
                    )
                }
            self.imageErrors.removeAll()
            self.applyMedia(items)
            for item in items { self.downloadImage(for: item) }
        }
    }

    private func downloadImage(for item: TeamMediaItem) {
        guard imageCache[item.foreignKey] == nil else { return }
        guard let url = item.directURL else { return }
        downloadTasks[item.foreignKey]?.cancel()
        downloadTasks[item.foreignKey] = Task { @MainActor [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    self?.imageCache[item.foreignKey] = image
                } else {
                    self?.imageErrors[item.foreignKey] = URLError(.cannotDecodeContentData)
                }
                self?.reconfigure(item: item)
            } catch {
                if !Task.isCancelled {
                    self?.imageErrors[item.foreignKey] = error
                    self?.reconfigure(item: item)
                }
            }
        }
    }

    private func reconfigure(item: TeamMediaItem) {
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
