import UIKit
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

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {

    func mediaSelected(_ media: TeamMedia)

}

class TeamMediaCollectionViewController: TBACollectionViewController {

    private let spacerSize: CGFloat = 3.0

    private let team: Team

    var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
        }
    }
    var dataSource: CollectionViewDataSource<TeamMedia, TeamMediaCollectionViewController>!
    weak var delegate: TeamMediaCollectionViewControllerDelegate?

    var fetchingMedia: NSHashTable<TeamMedia> = NSHashTable.weakObjects()

    // MARK: Init

    init(team: Team, year: Int? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.year = year

        super.init(persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true)]
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
            NSSortDescriptor(key: "type", ascending: false),
            NSSortDescriptor(key: "foreignKey", ascending: false),
            NSSortDescriptor(key: "key", ascending: false)
        ]
    }

    // MARK: - Private Methods

    private func indexPath(for media: TeamMedia) -> IndexPath? {
        return dataSource.fetchedResultsController.indexPath(forObject: media)
    }

    private func fetchMedia(_ media: TeamMedia) {
        // Make sure we can attempt to fetch our media
        guard let url = media.imageDirectURL else {
            self.persistentContainer.viewContext.performChanges {
                media.mediaError = MediaError.error("No url for media")
            }
            return
        }

        // Check if we're already fetching for this media - then lock out other fetches
        if fetchingMedia.contains(media) {
            return
        }
        fetchingMedia.add(media)

        // Reload our cell, so we can show a loading spinner
        if let indexPath = indexPath(for: media) {
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }

        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: { [unowned self] (data, _, error) in
            self.fetchingMedia.remove(media)

            if let error = error {
                media.mediaError = MediaError.error(error.localizedDescription)
            } else if let data = data {
                if let image = UIImage(data: data) {
                    media.image = image
                } else {
                    media.mediaError = MediaError.error("Invalid data for request")
                }
            } else {
                media.mediaError = MediaError.error("No data for request")
            }

            self.persistentContainer.viewContext.performSaveOrRollback()
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

    func configure(_ cell: MediaCollectionViewCell, for object: TeamMedia, at indexPath: IndexPath) {
        if fetchingMedia.contains(object) {
            cell.state = .loading
        } else if let image = object.image {
            cell.state = .loaded(image)
        } else if let error = object.mediaError {
            cell.state = .error("Error loading media - \(error.localizedDescription)")
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
            showNoDataView()
            refreshControl?.endRefreshing()
            return
        }

        removeNoDataView()

        let fetchTeamMedia: () -> () = { [unowned self] in
            if let teamMedia = self.team.media?.allObjects as? [TeamMedia] {
                teamMedia.forEach({ (media) in
                    self.fetchMedia(media)
                })
            }
        }

        var request: URLSessionDataTask?
        request = tbaKit.fetchTeamMedia(key: team.key!, year: year, completion: { (media, error) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if let media = media {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.insert(media, year: year)
                }
            }, saved: {
                self.markTBARefreshSuccessful(self.tbaKit, request: request!)
            })
            self.removeRequest(request: request!)

            DispatchQueue.main.async {
                fetchTeamMedia()
            }
        })
        addRequest(request: request!)
    }

}

extension TeamMediaCollectionViewController: Stateful {

    var noDataText: String {
        return "No media for team"
    }

}
