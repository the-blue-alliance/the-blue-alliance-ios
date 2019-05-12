import CoreData
import Foundation
import TBAKit
import UIKit

protocol ScrollableContainerView {
    var headerView: UIView { get }
    var headerContentView: UIView { get }
}

class ScrollableContainerViewController: ContainerViewController, ScrollableContainerView {

    var headerView: UIView {
        fatalError("Must override")
    }
    var headerContentView: UIView {
        fatalError("Must override")
    }

    private lazy var navigationStackView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubtitleLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        return navigationStackView
    }()
    private lazy var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = ContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        navigationTitleLabel.text = "Team 1"
        return navigationTitleLabel
    }()
    private lazy var navigationSubtitleLabel: UILabel = {
        let navigationSubtitleLabel = ContainerViewController.createNavigationLabel()
        navigationSubtitleLabel.font = UIFont.systemFont(ofSize: 11)
        navigationSubtitleLabel.text = "2019"
        return navigationSubtitleLabel
    }()

    let rootScrollView = ContainerScrollView()

    private var previousEndDraggingOffset: CGFloat = 0

    override init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String? = nil, segmentedControlTitles: [String]? = nil, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(viewControllers: viewControllers, navigationTitle: navigationTitle, navigationSubtitle: navigationSubtitle, segmentedControlTitles: segmentedControlTitles, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        // rootScrollView.delegate = self

        navigationItem.titleView = navigationStackView
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
        rootStackView.autoPinEdge(.bottom, to: .bottom, of: view)

        // firstTableView.addGestureRecognizer(rootScrollView.panGestureRecognizer)

        navigationStackView.alpha = 0.0
    }

    func hideHeaderView() {
        UIView.animate(withDuration: 1/3) {
            self.headerContentView.alpha = 0.0
            self.navigationStackView.alpha = 1.0
        }
    }

    func showHeaderView() {
        UIView.animate(withDuration: 1/3) {
            self.headerContentView.alpha = 1.0
            self.navigationStackView.alpha = 0.0
        }
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
        // If we haven't hit our header clipping yet, only scroll the root view
        let rootOffset = rootScrollView.contentOffset.y
        let tableViewOffset = scrollView.contentOffset.y

        let hidePoint = headerView.frame.height * (2/3)

        // If we're moving upwards -
        if tableViewOffset < 0 {
            // and we haven't hit our header yet, move us towards there
            if rootScrollView.contentOffset.y > 0 {
                let newOffset = max(rootScrollView.contentOffset.y + scrollView.contentOffset.y, 0) // Limit to 0
                rootScrollView.contentOffset.y = newOffset
                scrollView.contentOffset.y = 0

                if rootScrollView.contentOffset.y < hidePoint {
                    showHeaderView()
                }
            } else {
                rootScrollView.contentOffset.y = 0
            }
        } else if rootOffset < headerView.frame.height {
            let newOffset = min(rootScrollView.contentOffset.y + scrollView.contentOffset.y, headerView.frame.height) // Limit to header height
            rootScrollView.contentOffset.y = newOffset
            scrollView.contentOffset.y = 0

            if rootScrollView.contentOffset.y > hidePoint {
                hideHeaderView()
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // If our header is not in place, we'll get it to a good place
        guard rootScrollView.contentOffset.y > 0, rootScrollView.contentOffset.y < headerView.frame.height else {
            return
        }

        let percentageScrolled = rootScrollView.contentOffset.y / headerView.frame.height
        let scrollingUp = (previousEndDraggingOffset - rootScrollView.contentOffset.y) > 0

        // Half is like, a little much. I think we should probably set this to be 1/3

        // If we need to jump our header in place, scale the animation duration by the distance we have to go
        // The longer we have to go, the longer the animation will be.
        let animationDuration: Double = {
            let maxDuration = (1.0/3.0)
            let halfwayPoint = headerView.frame.height / 2
            if percentageScrolled < 0.5 {
                return Double(rootScrollView.contentOffset.y / halfwayPoint) * maxDuration
            } else {
                return Double((headerView.frame.height - rootScrollView.contentOffset.y) / halfwayPoint) * maxDuration
            }
        }()

        if percentageScrolled < 0.5 {
            // If we're scrolling up and we're over halfway there, jump to top
            UIView.animate(withDuration: animationDuration) {
                self.rootScrollView.contentOffset.y = 0
            }
            previousEndDraggingOffset = 0
        } else if percentageScrolled >= 0.5 {
            // If we're scrolling down and we're over halfway there, jump to bottom
            UIView.animate(withDuration: animationDuration) {
                self.rootScrollView.contentOffset.y = self.headerView.frame.height
            }
            previousEndDraggingOffset = self.headerView.frame.height
        } else {
            previousEndDraggingOffset = rootScrollView.contentOffset.y
        }
    }

}
