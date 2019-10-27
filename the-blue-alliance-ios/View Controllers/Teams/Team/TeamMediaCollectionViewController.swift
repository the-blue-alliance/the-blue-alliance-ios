import CoreData
import Crashlytics
import TBAData
import TBAKit
import UIKit

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {
    func mediaSelected(_ media: TeamMedia)
}

class TeamMediaCollectionViewController: TBACollectionViewController {

    private let spacerSize: CGFloat = 3.0

    private let team: Team
    private let fetchMediaOperationQueue = OperationQueue()

    var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }
    var dataSource: CollectionViewDataSource<TeamMedia, TeamMediaCollectionViewController>!
    weak var delegate: TeamMediaCollectionViewControllerDelegate?

    // MARK: Init

    init(team: Team, year: Int? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.year = year

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
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
        let media = dataSource.object(at: indexPath)
        delegate?.mediaSelected(media)
    }

    // MARK: Table View Data Source

    private func setupDataSource() {
        let fetchRequest: NSFetchRequest<TeamMedia> = TeamMedia.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TeamMedia.type), ascending: true)]
        setupFetchRequest(fetchRequest)

        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        dataSource = CollectionViewDataSource(fetchedResultsController: frc, delegate: self)
    }

    private func updateDataSource() {
        dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
    }

    private func setupFetchRequest(_ request: NSFetchRequest<TeamMedia>) {
        // TODO: Split section by photos/videos like we do on the web
        if let year = year {
            request.predicate = NSPredicate(format: "%K == %@ AND %K == %ld AND %K in %@",
                                            #keyPath(TeamMedia.team.key), team.key!,
                                            #keyPath(TeamMedia.year), year,
                                            #keyPath(TeamMedia.type), MediaType.imageTypes)
        } else {
            // Match none by passing a bosus year
            request.predicate = NSPredicate(format: "%K == %@ AND %K == 0",
                                            #keyPath(TeamMedia.team.key), team.key!,
                                            #keyPath(TeamMedia.type))
        }

        // Sort these by a lot of things, in an attempt to make sure that when refreshing,
        // images don't jump from to different places because the sort is too general
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TeamMedia.type), ascending: false),
            NSSortDescriptor(key: #keyPath(TeamMedia.foreignKey), ascending: false),
            NSSortDescriptor(key: #keyPath(TeamMedia.key), ascending: false)
        ]
    }

    // MARK: - Private Methods

    private func indexPath(for media: TeamMedia) -> IndexPath? {
        return dataSource.fetchedResultsController.indexPath(forObject: media)
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

    func configure(_ cell: MediaCollectionViewCell, for object: TeamMedia, at indexPath: IndexPath) {
        if let image = object.image {
            cell.state = .loaded(image)
        } else if let error = object.imageError {
            cell.state = .error("Error loading media - \(error.localizedDescription)")
        } else if isRefreshing {
            cell.state = .loading
        } else {
            cell.state = .error("Error loading media - unknown error")
        }
    }

}

extension TeamMediaCollectionViewController: Refreshable {

    var refreshKey: String? {
        guard let year = year else {
            return nil
        }
        let key = team.getValue(\Team.key!)
        return "\(year)_\(key)_media"
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
        operation = tbaKit.fetchTeamMedia(key: team.key!, year: year, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let media = try? result.get() {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.insert(media, year: year)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, operation: operation)
            }, errorRecorder: Crashlytics.sharedInstance())
        })
        let fetchMediaOperation = BlockOperation {
            guard let teamMedia = self.team.media?.allObjects as? [TeamMedia] else {
                return
            }
            for media in teamMedia {
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
