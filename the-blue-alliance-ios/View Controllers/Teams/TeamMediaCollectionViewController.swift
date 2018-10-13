import UIKit
import TBAKit
import CoreData

enum MediaError: Error {
    case error(String)
}

extension MediaError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .error(message):
            return NSLocalizedString(message, comment: "Media error")
        }
    }
}

class TeamMediaCollectionViewController: TBACollectionViewController, Refreshable {

    private let spacerSize: CGFloat = 3.0

    private let team: Team
    private let urlOpener: URLOpener

    var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }
    private var dataSource: CollectionViewDataSource<Media, TeamMediaCollectionViewController>!

    let imageCache = NSCache<NSURL, UIImage>()
    var mediaErrors: NSMapTable<Media, NSError> = NSMapTable.weakToStrongObjects()
    var fetchingMedia: NSHashTable<Media> = NSHashTable.weakObjects()

    // MARK: Init

    init(team: Team, year: Int? = nil, urlOpener: URLOpener, persistentContainer: NSPersistentContainer) {
        self.team = team
        self.year = year
        self.urlOpener = urlOpener

        super.init(persistentContainer: persistentContainer)

        setupDataSource()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(MediaCollectionViewCell.self)
    }

    // MARK: - Refreshable

    var refreshKey: String? {
        guard let year = year else {
            return nil
        }
        return "\(year)_\(team.key!)_media"
    }

    var automaticRefreshInterval: DateComponents? {
        return DateComponents(month: 1)
    }

    var automaticRefreshEndDate: Date? {
        // TODO: Show loading spinner and avoid methods until we have years
        guard let year = year else {
            return nil
        }
        // Automatically refresh team media until the year is over
        // Ex: Team media for 2018 will stop refreshing on Jan 1st, 2019
        return Calendar.current.date(from: DateComponents(year: year + 1))
    }

    var isDataSourceEmpty: Bool {
        if let media = dataSource.fetchedResultsController.fetchedObjects, media.isEmpty {
            return true
        }
        return false
    }

    @objc func refresh() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            refreshControl?.endRefreshing()
            return
        }

        // TODO: Move this `removeNoDataView` call to superclass, have classes call super.refresh to get that
        removeNoDataView()

        // Remove old cached data
        // Purposely don't remove cached images, since we're not storing images in Core Data yet
        mediaErrors.removeAllObjects()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeamMedia(key: team.key!, year: year, completion: { (media, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team media - \(error.localizedDescription)")
            } else {
                self.markRefreshSuccessful()
            }

            self.persistentContainer.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team
                if let media = media {
                    let localMedia = media.map({ (modelMedia) -> Media in
                        return Media.insert(with: modelMedia, in: year, for: backgroundTeam, in: backgroundContext)
                    })
                    backgroundTeam.media = Set(localMedia) as NSSet
                }

                backgroundContext.saveOrRollback()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    // MARK: Rotation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Eventually show the full image inside the app
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/43
        let media = dataSource.object(at: indexPath)
        guard let url = media.viewImageURL else {
            return
        }

        if urlOpener.canOpenURL(url) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = CollectionViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<Media>) {
        // TODO: Split section by photos/videos like we do on the web
        if let year = year {
            request.predicate = NSPredicate(format: "team == %@ AND year == %ld AND type in %@", team, year, MediaType.imageTypes)
        } else {
            // Match none by passing a bosus year
            request.predicate = NSPredicate(format: "team == %@ AND year == 0", team)
        }

        // Sort these by a lot of things, in an attempt to make sure that when refreshing,
        // images don't jump from to different places because the sort is too general
        request.sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: false),
            NSSortDescriptor(key: "foreignKey", ascending: false),
            NSSortDescriptor(key: "key", ascending: false)
        ]
    }

    // MARK: - Private Methods

    private func indexPath(for media: Media) -> IndexPath? {
        return dataSource.fetchedResultsController.indexPath(forObject: media)
    }

    // TODO: Store this shit in Core Data - can we ?
    private func fetchMedia(_ media: Media) {
        // Make sure we can attempt to fetch our media
        guard let url = media.imageDirectURL else {
            mediaErrors.setObject(MediaError.error("No url for media") as NSError, forKey: media)
            return
        }

        // If we already have a cached image, don't fetch again
        if let _ = imageCache.object(forKey: url as NSURL) {
            // Reload the cell in question, since it's confused about it's data
            if let mediaIndexPath = self.indexPath(for: media) {
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [mediaIndexPath])
                }
            }
            return
        }

        // Check if we're already fetching for this media - then lock out other fetches
        if fetchingMedia.contains(media) {
            return
        }
        fetchingMedia.add(media)

        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { [unowned self] (data, _, error) in
            self.fetchingMedia.remove(media)

            if let error = error {
                self.mediaErrors.setObject(error as NSError, forKey: media)
            } else if let data = data {
                if let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: url as NSURL)
                } else {
                    self.mediaErrors.setObject(MediaError.error("Invalid data for request") as NSError, forKey: media)
                }
            } else {
                self.mediaErrors.setObject(MediaError.error("No data for request") as NSError, forKey: media)
            }

            if let mediaIndexPath = self.indexPath(for: media) {
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [mediaIndexPath])
                }
            }
        })
        dataTask.resume()
    }


}

extension TeamMediaCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // TODO: Set 16:9 aspect ratio for videos
        let horizontalSizeClass = traitCollection.horizontalSizeClass

        var numberPerLine = 2
        if horizontalSizeClass == .regular {
            numberPerLine = 3
        }

        let viewWidth = collectionView.frame.size.width

        // cell space available = (viewWidth - (the space on the left/right of the cells) - (space needed for all the spacers))
        // cell width = cell space available / numberPerLine
        let cellWidth = (viewWidth - CGFloat(Int(spacerSize) * (numberPerLine + 1))) / CGFloat(numberPerLine)
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacerSize, left: spacerSize, bottom: spacerSize, right: spacerSize)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacerSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacerSize
    }

}

extension TeamMediaCollectionViewController: CollectionViewDataSourceDelegate {

    func configure(_ cell: MediaCollectionViewCell, for object: Media, at indexPath: IndexPath) {
        // Make sure we can attempt to fetch our media
        guard let url = object.imageDirectURL else {
            fatalError("Attempting to load media without url")
        }

        if let image = imageCache.object(forKey: url as NSURL) {
            cell.state = .loaded(image)
        } else if let error = mediaErrors.object(forKey: object) {
            cell.state = .error("Error loading media - \(error.localizedDescription)")
        } else {
            cell.state = .loading
            fetchMedia(object)
        }
    }

    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No media for team")
    }

    func hideNoDataView() {
        removeNoDataView()
    }

}
