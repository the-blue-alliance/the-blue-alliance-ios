//
//  ContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/11/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import UIKit

@MainActor protocol NavigationTitleDelegate: AnyObject {
    func navigationTitleViewTapped() async
}

protocol ContainerNavigationBarProvider: UIViewController {
    /// An array of UIBarButtonItems that the view controller wants to display
    /// in the container's navigation bar, typically on the right side.
    /// These items will be combined with any default items set by the container.
    var additionalRightBarButtonItems: [UIBarButtonItem] { get }

    // Potentially add in the future:
    // var additionalLeftBarButtonItems: [UIBarButtonItem] { get }
    // var customTitleView: UIView? { get }
    // var preferredLargeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode { get }
}

class ContainerViewController: UIViewController {

    private(set) weak var dependencyProvider: DependencyProvider!

    var navigationTitle: String? {
        didSet {
            title = navigationTitle
            navigationTitleLabel.text = navigationTitle
            updateTitleView()
        }
    }

    var navigationSubtitle: String? {
        didSet {
            navigationSubtitleLabel.text = navigationSubtitle
            updateTitleView()
        }
    }

    weak var navigationTitleDelegate: NavigationTitleDelegate?

    // MARK: - Private Properties

    private var shouldShowNavigationTitleView: Bool {
        if let navigationTitle, let navigationSubtitle {
            return !navigationTitle.isEmpty && !navigationSubtitle.isEmpty
        }
        return false
    }

    private var defaultRightBarButtonItems: [UIBarButtonItem]?

    // MARK: - View Elements

    private var navigationTitleLabel: UILabel = {
        let label = UILabel.headlineLabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private lazy var navigationSubtitleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            UIView(),
            navigationSubtitleLabel,
            navigationSubtitleImageView,
            UIView()
        ])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        navigationSubtitleImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationSubtitleImageView.heightAnchor.constraint(lessThanOrEqualTo: navigationSubtitleLabel.heightAnchor),
            navigationSubtitleImageView.widthAnchor.constraint(equalTo: navigationSubtitleImageView.heightAnchor)
        ])

        return stackView
    }()
    private var navigationSubtitleLabel: UILabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .white
        return label
    }()
    private lazy var navigationSubtitleImageView: UIImageView = {
        let image = UIImage(systemName: "chevron.down.circle.fill")
        let imageView = UIImageView(image: image)
        imageView.tintColor = .accentYellow
        return imageView
    }()
    private lazy var navigationTitleView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [
            navigationTitleLabel,
            navigationSubtitleStackView
        ])
        navigationStackView.axis = .vertical
        navigationStackView.alignment = .center

        navigationStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationTitleViewTapped)))
        return navigationStackView
    }()

    private lazy var segmentedControlView: TBASegmentedControl = {
        let segmentedControlView = TBASegmentedControl()
        // segmentedControlView.delegate = self
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControlView
    }()
    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    private var currentPageIndex = 0 {
        didSet {
            guard segmentedControlView.selectedIndex != currentPageIndex else {
                return
            }
            segmentedControlView.selectedIndex = currentPageIndex
        }
    }

    private lazy var rootStackView: UIStackView = {
        let rootStackView = UIStackView(arrangedSubviews: [segmentedControlView, pageViewController.view])
        rootStackView.axis = .vertical
        return rootStackView
    }()

    private lazy var offlineEventView: UIView = {
        let offlineEventLabel = UILabel()
        offlineEventLabel.translatesAutoresizingMaskIntoConstraints = false
        offlineEventLabel.text = "It looks like this event hasn't posted any results recently. It's possible that the internet connection at the event is down. The event's information might be out of date."
        offlineEventLabel.textColor = UIColor.dangerDarkRed
        offlineEventLabel.numberOfLines = 0
        offlineEventLabel.textAlignment = .center
        offlineEventLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)

        let offlineEventView = UIView()
        offlineEventView.backgroundColor = UIColor.dangerRed
        offlineEventView.addSubview(offlineEventLabel)

        offlineEventView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            offlineEventLabel.topAnchor.constraint(equalToSystemSpacingBelow: offlineEventView.layoutMarginsGuide.topAnchor, multiplier: 1.0),
            offlineEventLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: offlineEventView.layoutMarginsGuide.leadingAnchor, multiplier: 1.0),
            offlineEventLabel.trailingAnchor.constraint(equalToSystemSpacingAfter: offlineEventView.layoutMarginsGuide.trailingAnchor, multiplier: 1.0),
            offlineEventLabel.bottomAnchor.constraint(equalToSystemSpacingBelow: offlineEventView.layoutMarginsGuide.bottomAnchor, multiplier: 1.0)
        ])
        return offlineEventView
    }()

    // MARK: - Initialization

    init(dependencyProvider: DependencyProvider) {
        self.dependencyProvider = dependencyProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        defaultRightBarButtonItems = navigationItem.rightBarButtonItems

        view.addSubview(rootStackView)

        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootStackView.topAnchor.constraint(equalTo: view.topAnchor),
            rootStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControlView.heightAnchor.constraint(equalToConstant: 44.0)
        ])

        pageViewController.didMove(toParent: self)

        reloadData()
    }

    // MARK: - Data Source

    var numberOfContainedViewControllers: Int {
        return 0
    }

    func titleForSegment(at index: Int) -> String? {
        return nil
    }

    func viewControllerForSegment(at index: Int) -> UIViewController {
        fatalError("Implement in subclass")
    }

    // MARK: - Public Methods

    @MainActor public func showOfflineEventMessage(shouldShow: Bool, animated: Bool = true) {
        if shouldShow {
            if !rootStackView.arrangedSubviews.contains(offlineEventView) {
                // Animate our down events view in
                if animated {
                    offlineEventView.isHidden = true
                }
                rootStackView.addArrangedSubview(offlineEventView)
                if animated {
                    // iOS animation timing magic number
                    UIView.animate(withDuration: 0.35) { [weak self] in
                        self?.offlineEventView.isHidden = false
                    }
                }
            }
        } else {
            if animated {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    UIView.animate(withDuration: 0.35, animations: { [weak self] in
                        self?.offlineEventView.isHidden = true
                    }, completion: { [weak self] (_) in
                        guard let self else { return }
                        rootStackView.removeArrangedSubview(offlineEventView)
                        if offlineEventView.superview != nil {
                            offlineEventView.removeFromSuperview()
                        }
                        offlineEventView.isHidden = false
                    })
                }
            } else {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    rootStackView.removeArrangedSubview(offlineEventView)
                }
                if offlineEventView.superview != nil {
                    offlineEventView.removeFromSuperview()
                }
            }
        }
    }

    // MARK: - Private Methods

    @objc private func navigationTitleViewTapped() {
        Task {
            await navigationTitleDelegate?.navigationTitleViewTapped()
        }
    }

    @MainActor @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex

        // Determine the direction of the transition
        let direction: UIPageViewController.NavigationDirection
        // Compare the selected index to the current page index
        direction = selectedIndex > currentPageIndex ? .forward : .reverse

        displayViewController(at: selectedIndex, direction: direction)
    }

    @MainActor
    private func updateTitleView() {
        if shouldShowNavigationTitleView {
            navigationItem.titleView = navigationTitleView
        } else {
            navigationItem.titleView = nil
        }
    }

    @MainActor
    private func reloadData() {
        guard isViewLoaded else {
            return
        }

        let numberOfSegments = numberOfContainedViewControllers
        let tabTitles = (0..<numberOfSegments).compactMap {
            titleForSegment(at: $0)
        }
        segmentedControlView.configure(with: tabTitles)

        let direction: UIPageViewController.NavigationDirection = currentPageIndex > 0 ? .forward : .reverse
        if numberOfSegments > 1 {
            segmentedControlView.isHidden = false
        } else if numberOfSegments == 1 {
            segmentedControlView.isHidden = true
        } else {
            fatalError("Container view must contain some views!")
        }
        displayViewController(at: 0, direction: direction)
    }

    @MainActor
    private func displayViewController(at index: Int, direction: UIPageViewController.NavigationDirection) {
        guard index >= 0, index < numberOfContainedViewControllers else {
            fatalError("Container view out of range: \(index)")
        }

        let viewController = viewControllerForSegment(at: index)
        if pageViewController.viewControllers?.first == viewController {
            currentPageIndex = index
            updateNavigationBarItems(for: viewController)
            return
        }

        pageViewController.setViewControllers([viewController], direction: direction, animated: true) { [weak self] _ in
            guard let self else { return }
            // Note: assumes viewController will be our currently shown VC in the completion block
            // (a good assumption, but an assumption we COULD verify if we wanted)
            currentPageIndex = index
            updateNavigationBarItems(for: viewController)
        }
    }

    @MainActor
    private func updateNavigationBarItems(for viewController: UIViewController) {
        if let viewController = viewController as? ContainerNavigationBarProvider {
            navigationItem.rightBarButtonItems = (defaultRightBarButtonItems ?? []) + viewController.additionalRightBarButtonItems
        } else {
            navigationItem.rightBarButtonItems = defaultRightBarButtonItems
        }
    }

    private func indexOfViewController(_ viewController: UIViewController) -> Int? {
        for index in 0..<numberOfContainedViewControllers {
            let viewControllerForIndex = viewControllerForSegment(at: index)
            if viewControllerForIndex == viewController {
                return index
            }
        }
        return nil
    }

    /*
    @MainActor private func reloadViewController(_ viewController: UIViewController) {
        if let viewController = viewController as? TBAViewController {
            viewController.reloadData()
        } else if let viewController = viewController as? UITableViewController {
            viewController.tableView.reloadData()
        } else if let viewController = viewController as? UICollectionViewController {
            viewController.collectionView.reloadData()
        }
    }

    private func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }
    */

    // MARK: - Helper Methods

    private static func createNavigationLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }

}

// MARK: - UIPageViewControllerDataSource

extension ContainerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = indexOfViewController(viewController) else {
            return nil
        }

        let previousIndex = currentIndex - 1

        // Check if the previous index is valid
        guard previousIndex >= 0 && previousIndex < numberOfContainedViewControllers else {
            return nil
        }

        // Request and return the view controller for the previous index
        return viewControllerForSegment(at: previousIndex)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = indexOfViewController(viewController) else {
            return nil
        }

        let nextIndex = currentIndex + 1

        // Check if the next index is valid
        guard nextIndex < numberOfContainedViewControllers else {
            return nil
        }

        // Request and return the view controller for the next index
        return viewControllerForSegment(at: nextIndex)
    }
}

// MARK: - UIPageViewControllerDelegate

extension ContainerViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = indexOfViewController(currentViewController) {
            currentPageIndex = currentIndex // Update the stored current index
            updateNavigationBarItems(for: currentViewController)
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let pendingViewController = pendingViewControllers.first,
           let pendingIndex = indexOfViewController(pendingViewController) {
            currentPageIndex = pendingIndex
            updateNavigationBarItems(for: pendingViewController)
        }
    }
}
