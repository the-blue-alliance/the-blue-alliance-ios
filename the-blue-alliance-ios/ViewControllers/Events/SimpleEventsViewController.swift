//
//  SimpleEventsViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import UIKit
import Collections

protocol SimpleEventsViewControllerDelegate: AnyObject {
    func eventSelected(_ event: Event)
}

class SimpleEventsViewController: TBACollectionViewListController<EventCollectionViewListCell, Event> {

    // MARK: - Events View Controller Configuration

    class var firstEventKeyPathComparator: KeyPathComparator<Event> {
        KeyPathComparator(\.hybridType)
    }

    class var sectionKey: (Event) -> String {
        \.weekString
    }

    // MARK: - Public Properties

    weak var delegate: SimpleEventsViewControllerDelegate?

    // MARK: - Private(ish) Properties

    var events: [Event]? = nil {
        didSet {
            events?.sort(using: [
                Self.firstEventKeyPathComparator,
                KeyPathComparator(\.startDate),
                KeyPathComparator(\.name)
            ])
            if let events = events {
                eventsByType = OrderedDictionary(grouping: events, by: Self.sectionKey)
            } else {
                eventsByType = nil
            }
        }
    }
    private var eventsByType: OrderedDictionary<String, [Event]>? = nil {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateDataSource()
        }
    }

    // MARK: - Init

    init() {
        super.init(headerMode: .supplementary)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self

        setupDataSource()
    }

    // MARK: Collection View Data Source

    override var cellRegistration: UICollectionView.CellRegistration<EventCollectionViewListCell, Event> {
        UICollectionView.CellRegistration { cell, indexPath, event in
            cell.contentConfiguration = EventListContentConfiguration(event: event)
            cell.accessories = [.disclosureIndicator()]
        }
    }

    private func setupDataSource() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleCollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            guard let hybridType = dataSource.sectionIdentifier(for: indexPath.section) else { return }

            supplementaryView.title = hybridType
        }
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }

    @MainActor
    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        if let eventsByType {
            snapshot.appendSections(eventsByType.keys.elements)
            for (section, events) in eventsByType {
                snapshot.appendItems(events, toSection: section)
            }
        }
        dataSource.apply(snapshot)
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource, let event = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.eventSelected(event)
    }

}
