import Foundation
import UIKit
import CoreData

class ContainerViewController: UIViewController, Persistable, Alertable {

    var persistentContainer: NSPersistentContainer

    /*
    override var hidesBottomBarWhenPushed: Bool {
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    */

    private lazy var navigationStackView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationDetailLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        return navigationStackView
    }()
    private lazy var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = ContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return navigationTitleLabel
    }()
    private lazy var navigationDetailLabel: UILabel = {
        let navigationDetailLabel = ContainerViewController.createNavigationLabel()
        navigationDetailLabel.font = UIFont.systemFont(ofSize: 11)
        return navigationDetailLabel
    }()

    var navigationTitle: String? {
        didSet {
            navigationTitleLabel.text = navigationTitle
        }
    }
    var navigationSubtitle: String? {
        didSet {
            navigationDetailLabel.text = navigationSubtitle
        }
    }

    private let shouldShowSegmentedControl: Bool = false
    private lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView(forAutoLayout: ())
        segmentedControlView.backgroundColor = .primaryBlue
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    let segmentedControl: UISegmentedControl

    private let containerView: UIView = UIView()
    var viewControllers: [Refreshable & Stateful] {
        fatalError("Override viewControllers in subclass - \(String(describing: type(of: self)))")
    }

    init(segmentedControlTitles: [String]? = nil, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        segmentedControl = UISegmentedControl(items: segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = .primaryBlue
        segmentedControl.tintColor = .white

        super.init(nibName: nil, bundle: nil)

        navigationItem.titleView = navigationStackView
        segmentedControl.addTarget(self, action: #selector(updateSegmentedControlViews), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        // Remove segmentedControl if we don't need one
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }

        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        segmentedControlView.autoSetDimension(.height, toSize: 44.0)

        // Add subviews to view hiearchy in reverse order, so first one is showing automatically
        for viewController in viewControllers.reversed() {
            let containedView = viewController.dataView
            containerView.addSubview(containedView)
            containedView.autoPinEdgesToSuperviewSafeArea()
        }

        view.addSubview(stackView)
        view.insetsLayoutMarginsFromSafeArea = false
        stackView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        stackView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    @IBAction func segmentedControlValueChanged(sender: Any) {
        cancelRefreshes()
        updateSegmentedControlViews()
    }

    func switchedToIndex(_ index: Int) {}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        // TODO: Consider only canceling if we're moving backwards or sideways in the view hiearchy, if we have
        // access to that information. Ex: Teams -> Team, we don't need to cancel the teams refresh
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/176
        // if isMovingFromParentViewController {
        cancelRefreshes()
    }

    @objc func updateSegmentedControlViews() {
        if viewControllers.count == 1, let viewController = viewControllers.first {
            show(view: viewController.dataView)
        } else if viewControllers.count > segmentedControl.selectedSegmentIndex {
            show(view: viewControllers[segmentedControl.selectedSegmentIndex].dataView)
        }
    }

    private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containerView) in containerView.subviews.enumerated() {
            let shouldHide = !(containerView == showView)
            if !shouldHide {
                let refreshViewController = viewControllers[index]
                if refreshViewController.shouldRefresh() {
                    refreshViewController.refresh()
                }
                switchedIndex = index
            }
            containerView.isHidden = shouldHide
        }
        switchedToIndex(switchedIndex)
    }

    func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }

    // MARK: - Helper Methods

    static func createNavigationLabel() -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.textColor = .white
        label.textAlignment = .center
        return label
    }

}
