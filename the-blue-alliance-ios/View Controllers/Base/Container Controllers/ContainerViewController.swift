import Foundation
import UIKit
import CoreData

class ContainerViewController: UIViewController, Persistable, Alertable {

    var persistentContainer: NSPersistentContainer

    var navigationTitleLabel: UILabel
    var navigationDetailLabel: UILabel

    let segmentedControl: UISegmentedControl?
    private lazy var setupSegmentedControlViews: Void = { [unowned self] in
        self.updateSegmentedControlViews()
    }()

    let containerView: UIView = UIView()

    var viewControllers: [Stateful & Persistable & Refreshable] = [] {
        willSet {
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
        }
        didSet {
            // Add subviews to view hiearchy in reverse order, so first one is showing automatically
            for viewController in viewControllers.reversed() {
                containerView.addSubview(viewController.dataView)
            }
        }
    }

    /*
    var noDataViewController: NoDataViewController?
    */

    /*
    @IBOutlet var segmentedControl: UISegmentedControl?
    @IBOutlet var segmentedControlView: UIView? {
        didSet {
            segmentedControlView?.backgroundColor = .primaryBlue
        }
    }
    */

    init(segmentedControlTitles: [String]? = nil, persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer

        if let segmentedControlTitles = segmentedControlTitles {
            let segmentedControl = UISegmentedControl(items: segmentedControlTitles)
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.autoSetDimension(.height, toSize: 44.0)
            self.segmentedControl = segmentedControl
        }

        navigationTitleLabel = UILabel(forAutoLayout: ())
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)

        navigationDetailLabel = UILabel(forAutoLayout: ())
        navigationDetailLabel.font = UIFont.systemFont(ofSize: 11)

        for label in [navigationTitleLabel, navigationDetailLabel] {
            label.textColor = .white
            label.textAlignment = .center
        }

        super.init(nibName: nil, bundle: nil)

        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationDetailLabel])
        navigationStackView.axis = .vertical
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false

        navigationItem.titleView = navigationStackView

        segmentedControl?.addTarget(self, action: #selector(updateSegmentedControlViews), for: .valueChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        // Remove segmentedControl if we don't need one
        let arrangedSubviews = [segmentedControl, containerView].compactMap({ $0 })
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view = UIView(forAutoLayout: ())
        view.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    // TODO: Do we still need this???
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Equlivent of doing a dispatch_once in Obj-C
        // Only setup the segmented control views on view did appear the first time
        _ = setupSegmentedControlViews
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

}
