import UIKit
import TBAKit
import CoreData

class TeamMediaCollectionViewController: TBACollectionViewController {

    internal var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }
    var team: Team!

    var playerViews: [String: PlayerView] = [:]
    var downloadedImages: [String: UIImage] = [:]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        // When the VC changes sizes, make sure we invalidate our layout to adjust the sizes of the cells
        DispatchQueue.main.async {
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: - Refreshing

    override func refresh() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            refreshControl!.endRefreshing()
            return
        }

        removeNoDataView()

        var request: URLSessionDataTask?
        request = TBAKit.sharedKit.fetchTeamMedia(key: team.key!, year: year, completion: { (media, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team media - \(error.localizedDescription)")
            }

            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team

                // Fetch all old media for team for year
                let existingMedia = Media.fetch(in: backgroundContext, configurationBlock: { (request) in
                    self.setupFetchRequest(request)
                })
                backgroundTeam.removeFromMedia(Set(existingMedia) as NSSet)

                // Add/insert new media
                let localMedia = media?.map({ (modelMedia) -> Media in
                    return Media.insert(with: modelMedia, for: year, in: backgroundContext)
                })
                backgroundTeam.addToMedia(Set(localMedia ?? []) as NSSet)

                // Cleanup orphaned media
                existingMedia.filter({ $0.team == nil }).forEach {
                    backgroundContext.delete($0)
                }

                backgroundContext.saveContext()
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }

    override func shouldNoDataRefresh() -> Bool {
        if let media = dataSource?.fetchedResultsController.fetchedObjects, media.isEmpty {
            return true
        }
        return false
    }

    // MARK: Rotation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Eventually show the full image inside the app
        guard let media = dataSource?.object(at: indexPath) else {
            return
        }
        guard let url = media.viewImageURL else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: Table View Data Source

    fileprivate var dataSource: CollectionViewDataSource<Media, TeamMediaCollectionViewController>?

    fileprivate func setupDataSource() {
        // TODO: This seems like a weird place to check if we need a year, then not use the year
        guard let persistentContainer = persistentContainer, year != nil else {
            return
        }

        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true)]

        setupFetchRequest(fetchRequest)

        // TODO: Split section by photos/videos like we do on the web
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        dataSource = CollectionViewDataSource(collectionView: collectionView!, cellIdentifier: basicCellReuseIdentifier, fetchedResultsController: frc, delegate: self)
    }

    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }

    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Media>) {
        guard let year = year else {
            return
        }
        // TODO: Seems like if we don't have a year, we should just load all, right? Depends on when this gets set up
        // TODO: We could support GrabCAD here too if we wanted to
        request.predicate = NSPredicate(format: "team == %@ AND year == %ld AND type in %@", team, year, MediaType.imageTypes)
    }

    // MARK: - Private

    fileprivate func playerViewForMedia(_ media: Media) -> PlayerView {
        guard let foreignKey = media.foreignKey else {
            fatalError("Cannot load media")
        }

        var playerView = playerViews[foreignKey]
        if playerView == nil {
            playerView = PlayerView(playable: media)
            playerViews[foreignKey] = playerView!
        }

        return playerView!
    }

    fileprivate func mediaViewForMedia(_ media: Media) -> MediaView? {
        guard let foreignKey = media.foreignKey else {
            fatalError("Cannot load media")
        }
        let downloadedImage = downloadedImages[foreignKey]

        let mediaView = MediaView(media: media)
        mediaView.downloadedImage = downloadedImage
        mediaView.imageDownloaded = { [weak self] in
            self?.downloadedImages[foreignKey] = $0
        }

        return mediaView
    }

}

extension TeamMediaCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSizeClass = traitCollection.horizontalSizeClass

        var numberPerLine = 2
        if horizontalSizeClass == .regular {
            numberPerLine = 3
        }

        let spacerSize = 3
        let viewWidth = collectionView.frame.size.width

        // cell space available = (viewWidth - (the space on the left/right of the cells) - (space needed for all the spacers))
        // cell width = cell space available / numberPerLine
        let cellWidth = (viewWidth - CGFloat(spacerSize * (numberPerLine + 1))) / CGFloat(numberPerLine)
        return CGSize(width: cellWidth, height: cellWidth)
    }

}

extension TeamMediaCollectionViewController: CollectionViewDataSourceDelegate {

    func configure(_ cell: UICollectionViewCell, for object: Media, at indexPath: IndexPath) {
        var mediaView: UIView?
        if object.type == MediaType.youtubeVideo.rawValue {
            mediaView = playerViewForMedia(object)
        } else {
            mediaView = mediaViewForMedia(object)
        }
        cell.contentView.addSubview(mediaView!)
        mediaView!.autoPinEdgesToSuperviewEdges()
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
