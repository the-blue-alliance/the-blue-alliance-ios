//
//  SimpleContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/11/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import UIKit

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

    let api: TBAAPI

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
            return navigationTitle.isEmpty && !navigationSubtitle.isEmpty
        }
        return false
    }

    private var defaultRightBarButtonItems: [UIBarButtonItem]?

    private var currentViewController: UIViewController?

    // MARK: - View Elements

    private var navigationTitleLabel: UILabel = {
        let label = UILabel.bodyLabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private var navigationSubtitleLabel: UILabel = {
        let label = UILabel.caption2Label()
        label.textColor = .white
        label.textAlignment = .center
        return label
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
        segmentedControlView.backgroundColor = .navigationBarTintColor
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

    init(api: TBAAPI) {
        self.api = api

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
        rootStackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        rootStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)

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

        for index in 0..<numberOfContainedViewControllers {
            if let title = titleForSegment(at: index) {
                segmentedControl.insertSegment(withTitle: title, at: segmentedControl.numberOfSegments, animated: false)
            }
        }

        if numberOfContainedViewControllers > 1 {
            segmentedControlView.isHidden = false

            segmentedControl.selectedSegmentIndex = 0
            displayViewController(at: 0)
        } else if numberOfContainedViewControllers == 1 {
            segmentedControlView.isHidden = true

            displayViewController(at: 0)
        } else {
            fatalError("Container view must contain some views!")
        }
    }

    @MainActor
    private func displayViewController(at segmentedControlIndex: Int) {
        guard segmentedControlIndex >= 0, segmentedControlIndex < numberOfContainedViewControllers else {
            fatalError("Container view out of range: \(segmentedControlIndex)")
        }

        let viewController = viewControllerForSegment(at: segmentedControlIndex)
        if currentViewController == viewController {
            return
        }

        transition(from: currentViewController, to: viewController)
        currentViewController = viewController

        updateNavigationBarItems(for: viewController)
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
        if let viewController = viewController as? ContainerNavigationBarProvider {
            navigationItem.rightBarButtonItems = (defaultRightBarButtonItems ?? []) + viewController.additionalRightBarButtonItems
        } else {
            navigationItem.rightBarButtonItems = defaultRightBarButtonItems
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
