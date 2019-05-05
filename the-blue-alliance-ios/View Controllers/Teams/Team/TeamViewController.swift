import BFRImageViewer
import CoreData
import Firebase
import MyTBAKit
import Photos
import TBAKit
import UIKit

class TeamViewController: MyTBAContainerViewController, Observable {

    private(set) var team: Team
    private let statusService: StatusService
    private let urlOpener: URLOpener

    private(set) var infoViewController: TeamInfoViewController
    private(set) var eventsViewController: TeamEventsViewController
    private(set) var mediaViewController: TeamMediaCollectionViewController

    override var subscribableModel: MyTBASubscribable {
        return team
    }

    private var year: Int? {
        didSet {
            if let year = year {
                if eventsViewController.year != year {
                    eventsViewController.year = year
                }
                if mediaViewController.year != year {
                    mediaViewController.year = year
                }
            }

            updateInterface()
        }
    }
    private let yearButton = UIButton()

    // MARK: - Observable

    typealias ManagedType = Team
    lazy var contextObserver: CoreDataContextObserver<Team> = {
        return CoreDataContextObserver(context: persistentContainer.viewContext)
    }()

    // MARK: Init

    init(team: Team, statusService: StatusService, urlOpener: URLOpener, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.team = team
        self.statusService = statusService
        self.urlOpener = urlOpener
        self.year = TeamViewController.latestYear(currentSeason: statusService.currentSeason, years: team.yearsParticipated, in: persistentContainer.viewContext)

        infoViewController = TeamInfoViewController(team: team, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        eventsViewController = TeamEventsViewController(team: team, year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        mediaViewController = TeamMediaCollectionViewController(team: team, year: year, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        super.init(
            viewControllers: [infoViewController, eventsViewController, mediaViewController],
            navigationTitle: "",
            navigationSubtitle: nil,
            segmentedControlTitles: ["Info", "Events", "Media"],
            myTBA: myTBA,
            persistentContainer: persistentContainer,
            tbaKit: tbaKit,
            userDefaults: userDefaults
        )

        navigationTitleDelegate = self
        eventsViewController.delegate = self
        mediaViewController.delegate = self

        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let teamNameLabel = UILabel()
        teamNameLabel.text = team.nickname
        teamNameLabel.font = .preferredFont(forTextStyle: .title1, compatibleWith: nil)
        teamNameLabel.textColor = .white
        let teamNumberLabel = UILabel()
        teamNumberLabel.text = team.fallbackNickname
        teamNumberLabel.textColor = .white
        teamNameLabel.font = .preferredFont(forTextStyle: .title2, compatibleWith: nil)
        let teamNameStackView = UIStackView(arrangedSubviews: [teamNameLabel, teamNumberLabel])
        teamNameStackView.axis = .vertical
        let avatarImageView = UIImageView(image: UIImage(data: Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAALOQAACzkBycZ2YAAAAaFJREFUWEfNlcFKw0AQhvsAQsGDB48ehELBFxYPgkfvntT3KT34BLF/ZMpk8mW7a6KZwkfSf2c3H9PddHP6dMnBMBMYZgLDTGCYCQwzgWEmMFyd992d3Y8H1+bzYZdXUGJOTgwL1sTkZgseHq+6r9dtd3i6Pl9L0BoeL6afN4wPvlRBEpegdYSXE1AzCi5CAkVOHY9rRLEJOYFhEZSoQHNJDH5WD4aLEPcnydG8AIaL4OVMUHmDnMBwFiYQBf1YnFMAw2bebrb9g7Wf7J/Ay/kxml8Awyr6h7t3ooj77viyP8vRGhVgOAl1Z4qP/X3PDDmB4QDrgF3VpePzLUoZJqZaWrMBDAdCho2RkOG7pqtf85cMA0mZWBwzSMzmLSTl+bkxKZ1GN4iQnMR8psNBc5uRUKlbhJ1U65rwcsZCkhgW0QHxYsqiXCSu0QCGRWLXLPdCU/h1KsFwEu01k7NXTazxQpFYWwGGiMS0X2sfGutKtQUwHOEPUutDW2oBDAeoc5T/ExieaX0F/QEY9qzcOQPDTGCYCQwzgWEmMMwEhknYdN9zErNTMDfHmAAAAABJRU5ErkJggg==")!)!)
        avatarImageView.autoSetDimensions(to: CGSize(width: 50, height: 50))
        avatarImageView.layer.cornerRadius = 5
        // 487fcc and da3434
        avatarImageView.layer.borderColor = UIColor.colorWithRGB(rgbValue: 0xda3434).cgColor
        avatarImageView.layer.borderWidth = 5
        avatarImageView.layer.masksToBounds = true

        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let yearSpacerView = UIView()
        yearSpacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        yearButton.setTitle("---", for: .normal)
        yearButton.titleLabel?.font = .preferredFont(forTextStyle: .body, compatibleWith: nil)
        yearButton.setTitleColor(.primaryBlue, for: .normal)
        yearButton.backgroundColor = .white
        yearButton.layer.cornerRadius = 6
        yearButton.clipsToBounds = true
        yearButton.tintColor = .primaryBlue
        yearButton.setImage(UIImage(named: "baseline_arrow_drop_down"), for: .normal)
        yearButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 8)
        let buttonStackView = UIStackView(arrangedSubviews: [yearSpacerView, yearButton])
        buttonStackView.axis = .vertical

        let teamInfoView = UIStackView(arrangedSubviews: [avatarImageView, teamNameStackView, spacerView, buttonStackView])
        teamInfoView.spacing = 8
        teamInfoView.axis = .horizontal

        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .primaryBlue
        view.addSubview(teamInfoView)
        teamInfoView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        rootStackView.insertArrangedSubview(view, at: 0)

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: mediaViewController.collectionView)
        }

        refreshYearsParticipated()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Analytics.logEvent("team", parameters: ["team": team.key!])
    }

    // MARK: - Private

    private func setupObservers() {
        contextObserver.observeObject(object: team, state: .updated) { [weak self] (team, _) in
            guard let self = self else {
                return
            }
            guard let context = team.managedObjectContext else {
                fatalError("No context for Team.")
            }
            if self.year == nil {
                self.year = TeamViewController.latestYear(
                    currentSeason: self.statusService.currentSeason,
                    years: team.getValue(\Team.yearsParticipated),
                    in: context
                )
            } else {
                self.updateInterface()
            }
        }
    }

    private static func latestYear(currentSeason: Int, years: [Int]?, in context: NSManagedObjectContext) -> Int? {
        if let years = years, !years.isEmpty {
            // Limit default year set to be <= currentSeason
            let latestYear = years.first!
            if latestYear > currentSeason, years.count > 1 {
                // Find the next year before the current season
                return years.first(where: { $0 <= currentSeason })
            } else {
                // Otherwise, the first year is fine (for new teams)
                return years.first
            }
        }
        return nil
    }

    private func updateInterface() {
        let yearString: String = {
            if let year = year {
                return "\(year)"
            }
            return "---"
        }()
        yearButton.setTitle(yearString, for: .normal)
    }

    private func refreshYearsParticipated() {
        var request: URLSessionDataTask?
        request = tbaKit.fetchTeamYearsParticipated(key: team.key!, completion: { (result, notModified) in
            let context = self.persistentContainer.newBackgroundContext()
            context.performChangesAndWait({
                if !notModified, let years = try? result.get() {
                    let team = context.object(with: self.team.objectID) as! Team
                    team.yearsParticipated = years.sorted().reversed()
                }
            }, saved: {
                self.tbaKit.storeCacheHeaders(request!)
            })
        })
    }

    private func showSelectYear() {
        guard let yearsParticipated = team.yearsParticipated, !yearsParticipated.isEmpty else {
            return
        }

        let selectTableViewController = SelectTableViewController<TeamViewController>(current: year, options: yearsParticipated, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        selectTableViewController.title = "Select Year"
        selectTableViewController.delegate = self

        let nav = UINavigationController(rootViewController: selectTableViewController)
        nav.modalPresentationStyle = .formSheet
        nav.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSelectYear))

        navigationController?.present(nav, animated: true, completion: nil)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private func imageViewController(media: TeamMedia, peek: Bool = false) -> TeamMediaImageViewController? {
        // TODO: Support showing multiple images
        var imageViewController: TeamMediaImageViewController?
        if let image = media.image {
            let images = [image]
            // TODO: Inject these down from app delegate
            imageViewController = peek ?
                TeamMediaImageViewController(forPeekWithImageSource: images, pasteboard: UIPasteboard.general, photoLibrary: PHPhotoLibrary.shared()) :
                TeamMediaImageViewController(imageSource: images, pasteboard: UIPasteboard.general, photoLibrary: PHPhotoLibrary.shared())
        } else if let url = media.imageDirectURL {
            let urls = [url]
            imageViewController = peek ?
                TeamMediaImageViewController(forPeekWithImageSource: urls, pasteboard: UIPasteboard.general, photoLibrary: PHPhotoLibrary.shared()) :
                TeamMediaImageViewController(imageSource: urls, pasteboard: UIPasteboard.general, photoLibrary: PHPhotoLibrary.shared())
        }
        return imageViewController
    }

}

extension TeamViewController: NavigationTitleDelegate {

    func navigationTitleTapped() {
        showSelectYear()
    }

}

extension TeamViewController: SelectTableViewControllerDelegate {

    typealias OptionType = Int

    func optionSelected(_ option: Int) {
        year = option
    }

    func titleForOption(_ option: Int) -> String {
        return String(option)
    }

}

extension TeamViewController: EventsViewControllerDelegate {

    func eventSelected(_ event: Event) {
        let teamAtEventViewController = TeamAtEventViewController(teamKey: team.teamKey, event: event, myTBA: myTBA, showDetailEvent: true, showDetailTeam: false, statusService: statusService, urlOpener: urlOpener, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        self.navigationController?.pushViewController(teamAtEventViewController, animated: true)
    }

}

extension TeamViewController: TeamMediaCollectionViewControllerDelegate {

    func mediaSelected(_ media: TeamMedia) {
        if let imageViewController = self.imageViewController(media: media) {
            DispatchQueue.main.async {
                self.present(imageViewController, animated: true)
            }
        }
    }

}

extension TeamViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = mediaViewController.collectionView.indexPathForItem(at: location) else {
            return nil
        }
        guard let cell = mediaViewController.collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        let media = mediaViewController.dataSource.object(at: indexPath)

        let imageViewController = self.imageViewController(media: media, peek: true)
        if let image = media.image {
            imageViewController?.preferredContentSize = image.size
        } else {
            imageViewController?.preferredContentSize = CGSize(width: 200, height: 200)
        }
        previewingContext.sourceRect = cell.frame

        return imageViewController
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        present(viewControllerToCommit, animated: true)
        // This, to me, seems like a bug in BFRImageViewController. These notifications should be fired
        // by something else (maybe the system?) but they're not. So we're firing them manually.
        // However, this could be an iOS 12 thing, so we should check
        NotificationCenter.default.post(name: Notification.Name(NOTE_VC_POPPED), object: nil)
    }

}

class TeamMediaImageViewController: BFRImageViewController {

    // We're storing a second array of the images, which isn't great, but seems like the best we can do
    var images: [Any] = []
    var pasteboard: UIPasteboard? = nil
    var photoLibrary: PHPhotoLibrary? = nil

    init?(imageSource images: [Any], pasteboard: UIPasteboard?, photoLibrary: PHPhotoLibrary?) {
        super.init(imageSource: images)

        self.images = images
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
    }

    init?(forPeekWithImageSource images: [Any], pasteboard: UIPasteboard?, photoLibrary: PHPhotoLibrary?) {
        super.init(forPeekWithImageSource: images)

        self.images = images
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setImageSource(_ images: [Any]) {
        self.images = images

        super.setImageSource(images)
    }

    override var previewActionItems: [UIPreviewActionItem] {
        let copyAction = UIPreviewAction(title: "Copy", style: .default, handler: { [weak self] (_, _) in
            guard let index = self?.currentIndex else {
                return
            }
            guard let image = self?.images[index] as? UIImage else {
                return
            }
            self?.pasteboard?.image = image
        })

        let saveAction = UIPreviewAction(title: "Save", style: .default) { [weak self] (_, _) in
            guard let index = self?.currentIndex else {
                return
            }
            guard let image = self?.images[index] as? UIImage else {
                return
            }
            self?.photoLibrary?.performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: nil)
        }

        return [copyAction, saveAction]
    }

}
