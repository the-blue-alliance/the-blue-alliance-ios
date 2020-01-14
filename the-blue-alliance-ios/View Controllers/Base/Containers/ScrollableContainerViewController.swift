import CoreData
import Foundation
import MyTBAKit
import TBAKit
import UIKit

typealias ScrollableContainableViewController = ContainableViewController & ScrollReporter

class ScrollableHeaderContainerViewController: MyTBAContainerViewController {

    var headerView: UIView {
        fatalError("Implement headerView in a subclass")
    }

    var headerContentView: UIView {
        fatalError("Implement headerView in a subclass")
    }

    // MARK: - Header Properties

    private var previousScrollOffset: CGFloat = 0
    private var maximumHeaderHeight: CGFloat = 0
    private var headerHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(viewControllers: [ScrollableContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, myTBA: MyTBA, persistentContainer: NSPersistentContainer, tbaKit: TBAKit, userDefaults: UserDefaults) {
        super.init(viewControllers: viewControllers, navigationTitle: navigationTitle, navigationSubtitle: navigationSubtitle, segmentedControlTitles: segmentedControlTitles, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)

        viewControllers.forEach {
            $0.scrollReporterDelegate = self
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHeader()
    }

    // MARK: - Private Methods

    private func setupHeader() {
        rootStackView.insertArrangedSubview(headerView, at: 0)

        // Set our header view height to the height it would be at it's most compact
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        maximumHeaderHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        headerHeightConstraint = headerView.autoSetDimension(.height, toSize: maximumHeaderHeight)

        // Initially hide our navigation title view
        navigationItem.titleView?.isHidden = true
    }

}

extension ScrollableHeaderContainerViewController: ScrollReporterDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let headerHeightConstraint = headerHeightConstraint else {
            return
        }

        if !scrollView.isDecelerating, canAnimateHeader(scrollView) {
            let scrollDiff = scrollView.contentOffset.y - previousScrollOffset

            // Calculate new header height
            var newHeight = headerHeightConstraint.constant
            if scrollDiff > 0 {
                newHeight = max(0, headerHeightConstraint.constant - abs(scrollDiff))
            } else if scrollDiff < 0 {
                newHeight = min(maximumHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
            }

            if newHeight != headerHeightConstraint.constant {
                headerHeightConstraint.constant = newHeight
            }
            if let animation = updateHeaderAnimation() {
                animation.startAnimation()
            }
            setScrollPosition(scrollView, previousScrollOffset) // If we're scrolling the header, keep the scroll view at the old offset
        }
        previousScrollOffset = scrollView.contentOffset.y
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let headerHeightConstraint = headerHeightConstraint else {
            return
        }

        // If our header is not in place, we'll get it to a good place
        guard !headerAtFinalPosition() else {
            return
        }

        let percentage = headerHeightConstraint.constant / maximumHeaderHeight
        // At 50% scrolled either up or down, we'll jump to that direction
        let jumpPercentage = CGFloat(1.0 / 2.0)

        let shouldSnapToTop = percentage >= jumpPercentage
        let shouldSnapToBottom = percentage < jumpPercentage

        // If we need to jump our header in place, scale the animation duration
        // by the distance we have to go. The longer we have to go, the longer
        // the animation will be.
        let animationDuration: Double = {
            let maxDuration = (1.0/4.0)
            let halfwayPoint = self.maximumHeaderHeight / 2
            if shouldSnapToTop {
                // Headed to max height
                return Double((maximumHeaderHeight - headerHeightConstraint.constant) / halfwayPoint) * maxDuration
            } else if shouldSnapToBottom {
                // Headed to zero
                return Double(headerHeightConstraint.constant / halfwayPoint) * maxDuration
            }
            return maxDuration
        }()

        self.view.layoutIfNeeded()

        if shouldSnapToTop {
            headerHeightConstraint.constant = maximumHeaderHeight
        } else if shouldSnapToBottom {
            headerHeightConstraint.constant = 0
        }

        let animator = UIViewPropertyAnimator(duration: animationDuration, curve: .linear) {
            self.view.layoutIfNeeded()
        }
        var animations = [animator]
        if let headerAnimation = updateHeaderAnimation() {
            animations.append(headerAnimation)
        }
        animations.forEach { $0.startAnimation() }
    }

    // MARK: - Header

    private func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        guard let headerHeightConstraint = headerHeightConstraint else {
            return false
        }
        let canScrollUp = headerHeightConstraint.constant < maximumHeaderHeight && scrollView.contentOffset.y < 0
        let canScrollDown = headerHeightConstraint.constant > 0 && scrollView.contentOffset.y > 0
        return canScrollUp || canScrollDown
    }

    private func headerAtFinalPosition() -> Bool {
        guard let headerHeightConstraint = headerHeightConstraint else {
            return false
        }
        return headerHeightConstraint.constant == maximumHeaderHeight || headerHeightConstraint.constant == 0
    }

    private func setScrollPosition(_ scrollView: UIScrollView, _ position: CGFloat) {
        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: position)
    }

    private func updateHeaderAnimation() -> UIViewPropertyAnimator? {
        guard let headerHeightConstraint = headerHeightConstraint else {
            return nil
        }

        let hidePercentage = CGFloat(1.0/3.0)
        let percentage = headerHeightConstraint.constant / maximumHeaderHeight

        if percentage <= hidePercentage {
            return hideHeaderViewAnimation()
        } else if percentage > hidePercentage {
            return showHeaderViewAnimation()
        }
        return nil
    }

    private func hideHeaderViewAnimation() -> UIViewPropertyAnimator? {
        guard let titleView = navigationItem.titleView else {
            return nil
        }
        guard !headerContentView.isHidden, titleView.isHidden else {
            return nil
        }

        let animator = UIViewPropertyAnimator(duration: 1/3, curve: .linear) {
            titleView.alpha = 1.0
            self.headerContentView.alpha = 0.0
        }
        animator.addAnimations {
            titleView.isHidden = false
        }
        animator.addCompletion { _ in
            self.headerContentView.isHidden = true
        }
        return animator
    }

    private func showHeaderViewAnimation() -> UIViewPropertyAnimator? {
        guard let titleView = navigationItem.titleView else {
            return nil
        }
        guard headerContentView.isHidden, !titleView.isHidden else {
            return nil
        }

        let animator = UIViewPropertyAnimator(duration: 1/3, curve: .linear) {
            titleView.alpha = 0.0
            self.headerContentView.alpha = 1.0
        }
        animator.addAnimations {
            self.headerContentView.isHidden = false
        }
        animator.addCompletion { _ in
            titleView.isHidden = true
        }
        return animator
    }

}
