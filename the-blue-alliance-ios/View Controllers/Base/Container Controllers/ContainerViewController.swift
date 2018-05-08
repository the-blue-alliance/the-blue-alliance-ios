import Foundation
import UIKit
import CoreData

class ContainerViewController: UIViewController, Persistable, Alertable {
    
    var persistentContainer: NSPersistentContainer!
    var dataView: UIView {
        return view
    }
    var noDataViewController: NoDataViewController?
    private lazy var setupSegmentedControlViews: Void = { [weak self] in
        self?.updateSegmentedControlViews()
    }()
    
    var viewControllers: [Persistable & Refreshable] = [] {
        didSet {
            if let persistentContainer = persistentContainer {
                for controller in viewControllers {
                    let c = controller
                    c.persistentContainer = persistentContainer
                }
            }
        }
    }
    var containerViews: [UIView] = []
    
    @IBOutlet var navigationTitleLabel: UILabel? {
        didSet {
            navigationTitleLabel?.textColor = .white
        }
    }
    @IBOutlet var navigationDetailLabel: UILabel? {
        didSet {
            navigationDetailLabel?.textColor = .white
        }
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl?
    @IBOutlet var segmentedControlView: UIView? {
        didSet {
            segmentedControlView?.backgroundColor = .primaryBlue
        }
    }
    
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
        // if isMovingFromParentViewController {
        cancelRefreshes()
    }
    
    func updateSegmentedControlViews() {
        if segmentedControl == nil, containerViews.count == 1 {
            show(view: containerViews.first!)
        } else if let segmentedControl = segmentedControl, containerViews.count > segmentedControl.selectedSegmentIndex {
            show(view: containerViews[segmentedControl.selectedSegmentIndex])
        }
    }
    
    private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containerView) in containerViews.enumerated() {
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
