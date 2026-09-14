import Foundation
import MyTBAKit
import TBAAPI
import UIKit
import PureLayout

protocol Navigatable {
    // Protocol to allow container views to show right bar button items in their container view
    var additionalRightBarButtonItems: [UIBarButtonItem] { get }
    // Pinned between the segmented control and the list while this child is selected.
    var containerAccessoryView: UIView? { get }
}

typealias ContainableViewController = UIViewController & Refreshable & Navigatable

class ContainerViewController: UIViewController, Alertable, DependenciesProviding {

    // MARK: - Public Properties

    var navigationTitle: String? {
        didSet {
            setNeedsNavigationItemUpdate()
        }
    }

    var navigationSubtitle: String? {
        didSet {
            setNeedsNavigationItemUpdate()
        }
    }

    var rightBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            setNeedsNavigationItemUpdate()
        }
    }

    let dependencies: Dependencies

    // MARK: - Private View Elements

    lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView(forAutoLayout: ())
        segmentedControlView.autoSetDimension(.height, toSize: 44.0)
        segmentedControlView.backgroundColor = UIColor.navigationBarTintColor
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewSafeArea: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    private var segmentedControl: UISegmentedControl

    private let containerView: UIView = UIView()
    private let viewControllers: [any ContainableViewController]
    private var shownAccessoryView: UIView?
    lazy var rootStackView: UIStackView = {
        // Skip the segmented control when there's nothing to switch between
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var offlineEventView: UIView = {
        let offlineEventLabel = UILabel(forAutoLayout: ())
        offlineEventLabel.text =
            "It looks like this event hasn't posted any results recently. It's possible that the internet connection at the event is down. The event's information might be out of date."
        offlineEventLabel.textColor = UIColor.dangerDarkRed
        offlineEventLabel.numberOfLines = 0
        offlineEventLabel.textAlignment = .center
        offlineEventLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)

        let offlineEventView = UIView(forAutoLayout: ())
        offlineEventView.addSubview(offlineEventLabel)
        offlineEventLabel.autoPinEdgesToSuperviewSafeArea(
            with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        )
        offlineEventView.backgroundColor = UIColor.dangerRed
        return offlineEventView
    }()

    init(
        viewControllers: [any ContainableViewController],
        navigationTitle: String? = nil,
        navigationSubtitle: String? = nil,
        segmentedControlTitles: [String]? = nil,
        dependencies: Dependencies
    ) {
        self.viewControllers = viewControllers
        self.dependencies = dependencies

        self.navigationTitle = navigationTitle
        self.navigationSubtitle = navigationSubtitle

        segmentedControl = UISegmentedControl(items: segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .normal
        )
        segmentedControl.setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        // A white title needs a pill darker than the strip. It also survives the glass touch
        // lens, which can stay parked over the selection after a drag along the control.
        segmentedControl.selectedSegmentTintColor = UIColor.segmentedControlSelectedColor

        super.init(nibName: nil, bundle: nil)

        segmentedControl.addAction(
            UIAction { [weak self] _ in self?.updateSegmentedControlViews() },
            for: .valueChanged
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // The navigation bar is transparent. The blue behind it is this view showing through,
        // which is why the bar's text is white.
        view.backgroundColor = UIColor.navigationBarTintColor
        view.addSubview(rootStackView)

        rootStackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        rootStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        setNeedsUpdateProperties()
    }

    override func updateProperties() {
        super.updateProperties()

        navigationItem.title = navigationTitle
        navigationItem.subtitle = navigationSubtitle
        navigationItem.setRightBarButtonItems(
            rightBarButtonItems + (currentViewController()?.additionalRightBarButtonItems ?? []),
            animated: false
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSegmentedControlViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        // TODO: Consider only canceling if we're moving backwards or sideways in the view hierarchy, if we have
        // access to that information. Ex: Teams -> Team, we don't need to cancel the teams refresh
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/176
        if isMovingFromParent {
            cancelRefreshes()
        }
    }

    // MARK: - Public Methods

    func switchedToIndex(_ index: Int) {}

    func currentViewController() -> (any ContainableViewController)? {
        if viewControllers.count == 1, let viewController = viewControllers.first {
            return viewController
        } else if viewControllers.count > 0,
            viewControllers.count > segmentedControl.selectedSegmentIndex
        {
            return viewControllers[segmentedControl.selectedSegmentIndex]
        }
        return nil
    }

    static func yearSubtitle(_ year: Int?) -> String {
        if let year = year {
            return "\(year)"
        } else {
            return "----"
        }
    }

    func showOfflineEventMessage(shouldShow: Bool, animated: Bool = true) {
        if shouldShow {
            if !rootStackView.arrangedSubviews.contains(offlineEventView) {
                // Animate our down events view in
                if animated {
                    offlineEventView.isHidden = true
                }
                rootStackView.addArrangedSubview(offlineEventView)
                if animated {
                    // iOS animation timing magic number
                    UIView.animate(withDuration: 0.35) {
                        self.offlineEventView.isHidden = false
                    }
                }
            }
        } else {
            if animated {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    UIView.animate(
                        withDuration: 0.35,
                        animations: {
                            self.offlineEventView.isHidden = true
                        },
                        completion: { (_) in
                            self.rootStackView.removeArrangedSubview(self.offlineEventView)
                            if self.offlineEventView.superview != nil {
                                self.offlineEventView.removeFromSuperview()
                            }
                            self.offlineEventView.isHidden = false
                        }
                    )
                }
            } else {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    rootStackView.removeArrangedSubview(offlineEventView)
                }
                if offlineEventView.superview != nil {
                    self.offlineEventView.removeFromSuperview()
                }
            }
        }
    }

    // MARK: - Private Methods

    // Before the view loads there's nothing to update; `viewDidLoad` schedules the first pass.
    private func setNeedsNavigationItemUpdate() {
        guard isViewLoaded else { return }
        setNeedsUpdateProperties()
    }

    private func updateSegmentedControlViews() {
        if let viewController = currentViewController() {
            show(viewController)
        }
        setNeedsUpdateProperties()
    }

    // Tabs join the hierarchy the first time they're shown, so opening a screen doesn't build
    // every tab behind it.
    private func show(_ shownViewController: any ContainableViewController) {
        if shownViewController.parent !== self {
            addChild(shownViewController)
            containerView.addSubview(shownViewController.view)
            shownViewController.view.autoPinEdgesToSuperviewEdges()
            shownViewController.enableRefreshing()
            shownViewController.didMove(toParent: self)
        }
        for viewController in viewControllers where viewController.parent === self {
            viewController.view.isHidden = viewController !== shownViewController
        }
        showAccessoryView(of: shownViewController)
        shownViewController.refresh()
        switchedToIndex(segmentedControl.selectedSegmentIndex)
    }

    private func showAccessoryView(of viewController: any ContainableViewController) {
        let accessoryView = viewController.containerAccessoryView
        guard accessoryView !== shownAccessoryView else { return }
        shownAccessoryView?.removeFromSuperview()
        if let accessoryView,
            let index = rootStackView.arrangedSubviews.firstIndex(of: containerView)
        {
            rootStackView.insertArrangedSubview(accessoryView, at: index)
        }
        shownAccessoryView = accessoryView
    }

    private func cancelRefreshes() {
        // Tabs that were never shown have nothing to cancel, and touching them would load their views.
        for viewController in viewControllers where viewController.currentRefreshTask != nil {
            viewController.cancelRefresh()
        }
    }

    // MARK: - Helper Methods

    /// A capsule that opens a menu. Solid rather than glass so it reads the same whether the
    /// bar is over blue or over scrolled content.
    static func makeMenuButton(menu: UIMenu) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        // White on the blue in light so it stands off the bar; the segment pill's gray in dark.
        configuration.baseBackgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.systemGray2 : UIColor.white
        }
        configuration.baseForegroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.primaryBlue
        }
        configuration.image = UIImage(systemName: "chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 5
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            textStyle: .body,
            scale: .small
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 14,
            bottom: 8,
            trailing: 11
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var attributes = $0
            attributes.font = UIFontMetrics(forTextStyle: .body).scaledFont(
                for: UIFont.systemFont(ofSize: 17, weight: .semibold)
            )
            return attributes
        }
        let button = UIButton(configuration: configuration)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        return button
    }

    /// Wraps a menu button for the bar without the bar's own glass capsule around it, which
    /// would otherwise draw a second ring outside the button's.
    static func makeBarButtonItem(_ button: UIButton) -> UIBarButtonItem {
        let item = UIBarButtonItem(customView: button)
        item.hidesSharedBackground = true
        return item
    }

}
