import CoreData
import Foundation
import TBAKit
import UIKit

class ScrollableContainerViewController: ContainerViewController {

    let rootScrollView = ContainerScrollView()

    override init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String? = nil, segmentedControlTitles: [String]? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(viewControllers: viewControllers, navigationTitle: navigationTitle, navigationSubtitle: navigationSubtitle, segmentedControlTitles: segmentedControlTitles, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // rootScrollView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove segmentedControl if we don't need one
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }

        rootStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        // rootStackView.autoSetDimension(.height, toSize: 1600) // TODO: PROBLEMATIC

        rootScrollView.addSubview(rootStackView)

        // Add subviews to view hiearchy in reverse order, so first one is showing automatically
        for viewController in viewControllers.reversed() {
            addChild(viewController)
            containerView.addSubview(viewController.view)
            viewController.view.autoPinEdgesToSuperviewEdges()
            viewController.enableRefreshing()
        }

        if let tableViewController = viewControllers.first as? UITableViewController {
            firstTableView = tableViewController.tableView
            firstTableView.delegate = self
            print(tableViewController)
        }

        rootStackView.autoPinEdgesToSuperviewEdges()

        view.addSubview(rootScrollView)

        rootScrollView.autoPinEdge(toSuperviewEdge: .top)
        // Pin our scroll view underneath the safe area to extend underneath the home bar on notch phones
        rootScrollView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        rootScrollView.isScrollEnabled = false

        // Setup our scrollable area for our scroll view
        rootStackView.autoMatch(.width, to: .width, of: view)
        rootStackView.autoMatch(.height, to: .height, of: view)

        // firstTableView.addGestureRecognizer(rootScrollView.panGestureRecognizer)
    }

}

class ContainerScrollView: UIScrollView {

    /*
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit == self ? hit : nil
    }
    */

}

extension ScrollableContainerViewController: UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            // Don't do anything
        } else if rootScrollView.contentOffset.y < 90 {
            rootScrollView.contentOffset.y += scrollView.contentOffset.y
            scrollView.contentOffset.y = 0
        }
    }

    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        firstTableView.setContentOffset(.init(x: 0, y: 0), animated: true)
    }
    */

}
