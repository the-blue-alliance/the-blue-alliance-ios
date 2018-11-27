import Foundation
import UIKit
import CoreData

protocol NavigationTitleDelegate: AnyObject {
    func navigationTitleTapped()
}

typealias ContainableViewController = UIViewController & Refreshable & Persistable

class ContainerViewController: UIViewController, Persistable, Alertable {

    // MARK: - Public Properties

    var navigationTitle: String? {
        didSet {
            DispatchQueue.main.async {
                self.navigationTitleLabel.text = self.navigationTitle
            }
        }
    }

    var navigationSubtitle: String? {
        didSet {
            DispatchQueue.main.async {
                self.navigationSubtitleLabel.text = self.navigationSubtitle
            }
        }
    }

    // MARK: - Private Properties

    var persistentContainer: NSPersistentContainer
    private(set) var tbaKit: TBAKit
    private(set) var userDefaults: UserDefaults

    private var isRootContainerViewController: Bool {
        return navigationController?.topViewController != self
    }
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return isRootContainerViewController
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }

    // MARK: - Private View Elements

    private lazy var navigationStackView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubtitleLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        navigationStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationTitleTapped)))
        return navigationStackView
    }()
    private lazy var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = ContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return navigationTitleLabel
    }()
    private lazy var navigationSubtitleLabel: UILabel = {
        let navigationSubtitleLabel = ContainerViewController.createNavigationLabel()
        navigationSubtitleLabel.font = UIFont.systemFont(ofSize: 11)
        return navigationSubtitleLabel
    }()
    weak var navigationTitleDelegate: NavigationTitleDelegate?

    private let shouldShowSegmentedControl: Bool = false
    private lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView(forAutoLayout: ())
        segmentedControlView.autoSetDimension(.height, toSize: 44.0)
        segmentedControlView.backgroundColor = .primaryBlue
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    private let segmentedControl: UISegmentedControl

    private let containerView: UIView = UIView()
    private let viewControllers: [ContainableViewController]

    init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        self.viewControllers = viewControllers
        self.persistentContainer = persistentContainer
        self.tbaKit = tbaKit
        self.userDefaults = userDefaults

        self.navigationTitle = navigationTitle
        self.navigationSubtitle = navigationSubtitle

        segmentedControl = UISegmentedControl(items: segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.tintColor = .white

        super.init(nibName: nil, bundle: nil)

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        if let navigationTitle = navigationTitle, let navigationSubtitle = navigationSubtitle {
            navigationTitleLabel.text = navigationTitle
            navigationSubtitleLabel.text = navigationSubtitle
            navigationItem.titleView = navigationStackView
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove segmentedControl if we don't need one
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }

        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        view.addSubview(stackView)

        // Add subviews to view hiearchy in reverse order, so first one is showing automatically
        for viewController in viewControllers.reversed() {
            addChild(viewController)
            containerView.addSubview(viewController.view)
            viewController.view.autoPinEdgesToSuperviewEdges()
            viewController.enableRefreshing()
        }

        stackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        stackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSegmentedControlViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        // TODO: Consider only canceling if we're moving backwards or sideways in the view hiearchy, if we have
        // access to that information. Ex: Teams -> Team, we don't need to cancel the teams refresh
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/176
        if isMovingFromParent {
            cancelRefreshes()
        }
    }

    // MARK: - Public Methods

    public func switchedToIndex(_ index: Int) {}

    public func currentViewController() -> ContainableViewController? {
        if viewControllers.count == 1, let viewController = viewControllers.first {
            return viewController
        } else if viewControllers.count > 0, viewControllers.count > segmentedControl.selectedSegmentIndex {
            return viewControllers[segmentedControl.selectedSegmentIndex]
        }
        return nil
    }

    public static func yearSubtitle(_ year: Int?) -> String {
        if let year = year {
            return "▾ \(year)"
        } else {
            return "▾ ----"
        }
    }

    // MARK: - Private Methods

    @objc private func segmentedControlValueChanged() {
        updateSegmentedControlViews()
    }

    private func updateSegmentedControlViews() {
        if let viewController = currentViewController() {
            show(view: viewController.view)
        }
    }

    private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containedView) in viewControllers.compactMap({ $0.view }).enumerated() {
            let shouldHide = !(containedView == showView)
            if !shouldHide {
                let refreshViewController = viewControllers[index]
                if refreshViewController.shouldRefresh() {
                    refreshViewController.refresh()
                }
                switchedIndex = index
            }
            containedView.isHidden = shouldHide
        }
        switchedToIndex(switchedIndex)
    }

    private func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }

    @objc private func navigationTitleTapped() {
        navigationTitleDelegate?.navigationTitleTapped()
    }

    // MARK: - Helper Methods

    private static func createNavigationLabel() -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

}
