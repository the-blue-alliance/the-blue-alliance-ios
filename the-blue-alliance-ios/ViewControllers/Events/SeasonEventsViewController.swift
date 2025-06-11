//
//  SeasonEventsViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 5/3/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI
import UIKit

class SeasonEventsViewController: ContainerViewController {

    private(set) var year: Int {
        didSet {
            events = nil
            guard isViewLoaded else { return }
            // TODO: Could figure this out for one at a time...
            Task {
                try await performRefresh()
            }
            updateNavigationTitle()
        }
    }
    private(set) var eventWeek: EventWeek? {
        didSet {
            guard isViewLoaded else { return }
            updateEvents()
            updateNavigationTitle()
        }
    }
    private lazy var eventsViewController: SeasonEventsCollectionViewController = {
        let eventsViewController = SeasonEventsCollectionViewController(
            dependencyProvider: dependencyProvider
        )
        eventsViewController.refreshDelegate = self
        eventsViewController.delegate = self
        return eventsViewController
    }()

    private var events: [SeasonEvent]? {
        didSet {
            eventsByWeek = events?.groupedByWeek()
            eventWeek = events?.nextOrFirstEvent()?.eventWeek
        }
    }
    private var eventsByWeek: [EventWeek: [SeasonEvent]]? {
        didSet {
            guard isViewLoaded else { return }
            updateEvents()
        }
    }

    override init(dependencyProvider: any DependencyProvider) {
        self.year = dependencyProvider.statusService.currentSeason

        super.init(dependencyProvider: dependencyProvider)

        navigationTitleDelegate = self
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateNavigationTitle()

        navigationController?.setupSplitViewLeftBarButtonItem(viewController: self)
    }

    // MARK: - Private Methods

    @MainActor
    private func updateNavigationTitle() {
        navigationTitle = "\(eventWeek?.description ?? "---") Events"
        navigationSubtitle = String(year)
    }

    @MainActor
    private func updateEvents() {
        if let eventsByWeek, let eventWeek, let weekEvents = eventsByWeek[eventWeek] {
            eventsViewController.events = weekEvents.map { $0.event }
        } else {
            eventsViewController.events = nil
        }
    }

    // MARK: Container Data Source

    override var numberOfContainedViewControllers: Int {
        return 1
    }

    override func viewControllerForSegment(at index: Int) -> UIViewController {
        return eventsViewController
    }

}

extension SeasonEventsViewController: SeasonEventsRefreshDelegate {
    func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }
        let response = try await api.getEventsByYear(path: .init(year: year))
        events = try response.ok.body.json.compactMap { SeasonEvent(event: $0) }
    }
}

extension SeasonEventsViewController: NavigationTitleDelegate {
    @MainActor
    func navigationTitleViewTapped() {
        let statusService = dependencyProvider.statusService
        let yearSelectView = YearWeekSelectView(year: year, week: eventWeek, minYear: 1992, maxYear: statusService.maxSeason) { yearWeek in
            print(yearWeek)
        }
        yearSelectView.api(api: dependencyProvider.api)

        let hostingController = UIHostingController(rootView: yearSelectView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(hostingController, animated: true)
    }

    @objc private func dismissSelectYear() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension SeasonEventsViewController: EventsViewControllerDelegate {
    func eventSelected(_ event: Event) {
        // Pass
    }
}

private protocol SeasonEventsRefreshDelegate: AnyObject {
    func performRefresh() async throws
}

private class SeasonEventsCollectionViewController: EventsViewController {

    // TODO: This can go back to... not this?
    override class var firstEventSortKeyPathComparators: [KeyPathComparator<Event>] {
        [KeyPathComparator(\.eventWeek)]
    }

    override class var sectionKey: (Event) -> String {
        \.eventWeek!.description
    }

    weak var refreshDelegate: SeasonEventsRefreshDelegate?

    // MARK: - Refreshable

    override func performRefresh() async throws {
        try await refreshDelegate?.performRefresh()
    }

    // MARK: - Stateful

    override var noDataText: String? {
        "No events for season"
    }

}
