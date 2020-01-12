import CoreData
import Crashlytics
import Photos
import TBAData
import TBAKit
import UIKit

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {
    func mediaSelected(_ media: TeamMedia)
}

class TeamMediaCollectionViewController: TBACollectionViewController {

    private let spacerSize: CGFloat = 3.0

    private let team: Team
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let urlOpener: URLOpener?

    var year: Int? {
        didSet {
            updateDataSource()
        }
    }

    private let fetchMediaOperationQueue = OperationQueue()

    weak var delegate: TeamMediaCollectionViewControllerDelegate?
    private var dataSource: CollectionViewDataSource<String, TeamMedia>!
    var fetchedResultsController: CollectionViewDataSourceFetchedResultsController<TeamMedia>!

    // MARK: Init

    init(team: Team, year: Int? = nil, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, urlOpener: URLOpener? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.year = year
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.urlOpener = urlOpener

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(MediaCollectionViewCell.self)

        setupDataSource()
        collectionView.dataSource = dataSource
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        fetchMediaOperationQueue.cancelAllOperations()
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
        guard let media = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.mediaSelected(media)
    }

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let media = fetchedResultsController.dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        let configuration = UIContextMenuConfiguration(identifier: media.objectID, previewProvider: nil) { _ in
            let viewAction = UIAction(title: "View", image: UIImage(systemName: "eye.fill")) { _ in
                self.delegate?.mediaSelected(media)
            }
            var actions: [UIMenuElement] = [viewAction]

            if let viewURL = media.viewURL, let url = URL(string: viewURL), let urlOpener = self.urlOpener, urlOpener.canOpenURL(url) {
                let viewOnlineAction = UIAction(title: "View Online", image: UIImage(systemName: "safari.fill")) { _ in
                    urlOpener.open(url, options: [:], completionHandler: nil)
                }
                actions.append(viewOnlineAction)
            }

            if let image = media.image, let pasteboard = self.pasteboard {
                let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc.fill")) { _ in
                    pasteboard.image = image
                }
                actions.append(copyAction)
            }

            if let image = media.image, let photoLibrary = self.photoLibrary {
                let saveAction = UIAction(title: "Save", image: UIImage(systemName: "square.and.arrow.down.fill")) { _ in
                    photoLibrary.performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }, completionHandler: nil)
                }
                actions.append(saveAction)
            }
            return UIMenu(title: "", children: actions)
        }
        return configuration
    }

    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let objectID = configuration.identifier as? NSManagedObjectID else {
            return
        }
        guard let media = persistentContainer.viewContext.object(with: objectID) as? TeamMedia else {
            return
        }
        delegate?.mediaSelected(media)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let dataSource = UICollectionViewDiffableDataSource<String, TeamMedia>(collectionView: collectionView) { [weak self ] (collectionView, indexPath, media) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(indexPath: indexPath) as MediaCollectionViewCell
            if let image = media.image {
                cell.state = .loaded(image)
            } else if let error = media.imageError {
                cell.state = .error("Error loading media - \(error.localizedDescription)")
            } else if self?.isRefreshing ?? false {
                cell.state = .loading
            } else {
                cell.state = .error("Error loading media - unknown error")
            }
            return cell
        }
        self.dataSource = CollectionViewDataSource(dataSource: dataSource)
        self.dataSource.delegate = self

        let fetchRequest: NSFetchRequest<TeamMedia> = TeamMedia.fetchRequest()
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = CollectionViewDataSourceFetchedResultsController(dataSource: dataSource, fetchedResultsController: frc)
    }

    private func updateDataSource() {
        fetchedResultsController.reconfigureFetchRequest(setupFetchRequest(_:))

        if shouldRefresh() {
            refresh()
        }
    }

    private func setupFetchRequest(_ request: NSFetchRequest<TeamMedia>) {
        // TODO: Split section by photos/videos like we do on the web
        if let year = year {
            request.predicate = TeamMedia.teamYearImagesPrediate(teamKey: team.key, year: year)
        } else {
            // Match none by passing a bosus year
            request.predicate = TeamMedia.nonePredicate(teamKey: team.key)
        }

        // Sort these by a lot of things, in an attempt to make sure that when refreshing,
        // images don't jump from to different places because the sort is too general
        request.sortDescriptors = TeamMedia.sortDescriptors()
    }

    // MARK: - Private Methods

    private func indexPath(for media: TeamMedia) -> IndexPath? {
        return fetchedResultsController.fetchedResultsController.indexPath(forObject: media)
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

extension TeamMediaCollectionViewController: Refreshable {

    var refreshKey: String? {
        guard let year = year else {
            return nil
        }
        return "\(year)_\(team.key)_media"
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
        return fetchedResultsController.isDataSourceEmpty
    }

    @objc func refresh() {
        guard let year = year else {
            updateRefresh()
            return
        }

        // Order of operations here is a little confusing - the ideas is:
        // 1) Show spinner, to show that we're refreshing.
        // 2) Fetch/Insert Team Media happens first, since we need to know what URLs to be fetching.
        // 3) Kickoff Media downloads for each URL - switch to the main thread for this, so we can query.
        //    `team.media` and we can get main-thread objects, not background thread objects. This will be
        //    important later when we're updating our cell states.
        // 4) Download Media, with the addition of updating our TeamMedia object.
        // 5) Refresh our Team Media cell - this is the important part for using main thread objects, since
        //    we query for this information using our `dataSource.fetchedResultsController`, which is tied
        //    to our `persistentContainer.viewContext`. We also do individual refreshes as opposed to a full
        //    collection view refresh so our media gently loads in, as opposed to several harsh refreshes.
        // 6) End refreshing, after all of our individual cells have some state. We could end earlier and
        //    default to letting the cell loading spinners do the UI work to indicate we're still downloading
        //    some information, but keeping the view refreshing has two benifits. First, it shows some activity
        //    in the case that the previous cells have some state (we don't unload images from cells on refresh),
        //    and second, it prevents a user from refreshing again and queueing duplicate media download actions,
        //    which can be expensive.

        var finalOperation: Operation!

        var operation: TBAKitOperation!
        operation = tbaKit.fetchTeamMedia(key: team.key, year: year) { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let media = try? result.get() {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.insert(media, year: year)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        }
        let fetchMediaOperation = BlockOperation {
            for media in self.team.media {
                self.fetchMedia(media, finalOperation)
            }
        }
        fetchMediaOperation.addDependency(operation)
        OperationQueue.main.addOperation(fetchMediaOperation)

        finalOperation = addRefreshOperations([operation])
        finalOperation.addDependency(fetchMediaOperation)
    }

    private func fetchMedia(_ media: TeamMedia, _ dependentOperation: Operation) {
        let refreshOperation = BlockOperation { [weak self] in
            guard let self = self else { return }
            // Reload our cell, so we can get rid of our loading state
            if let indexPath = self.indexPath(for: media) {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }

        let fetchMediaOperation = FetchMediaOperation(media: media, persistentContainer: persistentContainer)
        refreshOperation.addDependency(fetchMediaOperation)
        [fetchMediaOperation, refreshOperation].forEach {
            dependentOperation.addDependency($0)
        }

        OperationQueue.main.addOperation(refreshOperation)
        fetchMediaOperationQueue.addOperation(fetchMediaOperation)
    }

}

extension TeamMediaCollectionViewController: Stateful {

    var noDataText: String {
        return "No media for team"
    }

}
