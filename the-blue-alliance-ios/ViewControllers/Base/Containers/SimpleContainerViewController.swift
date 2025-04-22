//
//  SimpleContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/11/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import TBAUtils
import UIKit

protocol ContainerDataSource: NSObjectProtocol {
    /// Asks the data source for the total number of segments the container should potentially manage.
    func numberOfSegments(in containerViewController: SimpleContainerViewController) -> Int

    /// Asks the data source for the title for a segment at a specific index (corresponding to the index from numberOfSegments).
    /// Return nil if the segment at this index should *not* have a segmented control title.
    func containerViewController(_ containerViewController: SimpleContainerViewController, titleForSegmentAt index: Int) -> String?

    /// Asks the data source for the view controller to display for a segment at a specific index.
    /// This index corresponds to the index from numberOfSegments.
    /// Implementations should typically perform lazy loading and caching here.
    func containerViewController(_ containerViewController: SimpleContainerViewController, viewControllerForSegmentAt index: Int) -> UIViewController
}

extension ContainerDataSource where Self: SimpleContainerViewController {
    func numberOfSegments(in containerViewController: SimpleContainerViewController) -> Int {
        return 1
    }

    func containerViewController(_ containerViewController: SimpleContainerViewController, titleForSegmentAt index: Int) -> String? {
        return nil
    }
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

class SimpleContainerViewController: UIViewController, Alertable {

    let dependencies: Dependencies

    weak var dataSource: ContainerDataSource? {
        didSet {
            guard isViewLoaded else {
                return
            }
            reloadData()
        }
    }

    var navigationTitle: String? {
        didSet {
            title = navigationTitle
            navigationTitleLabel.text = navigationTitle
        }
    }

    var navigationSubtitle: String? {
        didSet {
            navigationSubtitleLabel.text = navigationSubtitle

            updateTitleView()
        }
    }

    weak var navigationTitleDelegate: NavigationTitleDelegate?

    // MARK: - Internal Properties

    private var shouldShowNavigationTitleView: Bool {
        if let navigationSubtitle {
            return !navigationSubtitle.isEmpty
        }
        return false
    }

    private var currentViewController: UIViewController?

    // MARK: - View Elements

    private var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = SimpleContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return navigationTitleLabel
    }()
    private var navigationSubtitleLabel: UILabel = {
        let navigationSubtitleLabel = SimpleContainerViewController.createNavigationLabel()
        navigationSubtitleLabel.font = UIFont.systemFont(ofSize: 11)
        return navigationSubtitleLabel
    }()
    private lazy var navigationTitleView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubtitleLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        navigationStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationTitleViewTapped)))
        return navigationStackView
    }()

    private lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView()
        segmentedControlView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlView.autoSetDimension(.height, toSize: 44.0)
        segmentedControlView.backgroundColor = UIColor.navigationBarTintColor
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var rootStackView: UIStackView = {
        let rootStackView = UIStackView(arrangedSubviews: [segmentedControlView, containerView])
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
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
        offlineEventView.translatesAutoresizingMaskIntoConstraints = false
        offlineEventView.addSubview(offlineEventLabel)
        offlineEventLabel.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        offlineEventView.backgroundColor = UIColor.dangerRed
        return offlineEventView
    }()

    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(rootStackView)
        rootStackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        rootStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

        // Reload content from the data source if it was set before viewDidLoad
        if dataSource != nil {
            reloadData()
        } else {
            // Show empty state initially if no data source is set
            // showEmptyContainerState(text: "No data source set.")
        }
    }

    // MARK: - Public Methods

    public static func yearSubtitle(_ year: Int?) -> String {
        if let year = year {
            return "▾ \(year)"
        } else {
            return "▾ ----"
        }
    }

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
                    UIView.animate(withDuration: 0.35) {
                        self.offlineEventView.isHidden = false
                    }
                }
            }
        } else {
            if animated {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.offlineEventView.isHidden = true
                    }, completion: { (_) in
                        self.rootStackView.removeArrangedSubview(self.offlineEventView)
                        if self.offlineEventView.superview != nil {
                            self.offlineEventView.removeFromSuperview()
                        }
                        self.offlineEventView.isHidden = false
                    })
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

    @objc private func navigationTitleViewTapped() {
        // TODO: Update name to navigationTitleViewTapped ?
        navigationTitleDelegate?.navigationTitleTapped()
    }

    @MainActor @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        displayViewController(at: sender.selectedSegmentIndex)
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

        segmentedControl.removeAllSegments()
        transition(from: currentViewController, to: nil)
        currentViewController = nil

        guard let dataSource else {
            return
        }

        let numberOfSegments = dataSource.numberOfSegments(in: self)
        for i in 0..<numberOfSegments {
            if let title = dataSource.containerViewController(self, titleForSegmentAt: i) {
                segmentedControl.insertSegment(withTitle: title, at: segmentedControl.numberOfSegments, animated: false)
            }
        }

        if numberOfSegments > 1 {
            segmentedControlView.isHidden = false

            segmentedControl.selectedSegmentIndex = 0
            displayViewController(at: 0)
        } else if numberOfSegments == 1 {
            segmentedControlView.isHidden = true

            displayViewController(at: 0)
        } else {
            // TODO: Can show some no data view here
        }
    }

    @MainActor
    private func displayViewController(at segmentedControlIndex: Int) {
        guard let dataSource = self.dataSource else {
            return
        }

        // TODO: We need to make sure we're not out-of-range here by passing a index=0 where there's no views
        let viewController = dataSource.containerViewController(self, viewControllerForSegmentAt: segmentedControlIndex)

        if currentViewController == viewController {
            return
        }

        // Perform the transition from the current VC to the new one
        transition(from: currentViewController, to: viewController)
        currentViewController = viewController

        updateNavigationBarItems(for: viewController)

        // TODO: Update some currentViewController stuff here...
        /*
        if let emptyStateVC = currentViewController as? ChildContentEmptyState {
            emptyStateVC.updateEmptyStateUI()
        }
        */
    }

    @MainActor
    private func transition(from oldVC: UIViewController?, to newVC: UIViewController?) {
        if let oldVC = oldVC {
            oldVC.willMove(toParent: nil)
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }

        if let newVC = newVC {
            addChild(newVC)
            containerView.addSubview(newVC.view)

            newVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])

            newVC.didMove(toParent: self)
        }
    }

    @MainActor
    private func updateNavigationBarItems(for viewController: UIViewController) {
        // TODO: Set this as some default or something
         var rightBarButtonItems: [UIBarButtonItem] = []

        if let viewController = viewController as? ContainerNavigationBarProvider {
            navigationItem.rightBarButtonItems = rightBarButtonItems + viewController.additionalRightBarButtonItems
        }
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
