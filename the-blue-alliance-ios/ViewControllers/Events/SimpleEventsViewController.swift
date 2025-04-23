//
//  SimpleEventsViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAModels
import TBAAPI
import UIKit
import Collections

protocol SimpleEventsViewControllerDelegate: AnyObject {
    func title(for event: Event) -> String?
    func eventSelected(_ event: Event)
}

class SimpleEventsViewController: TBAFakeTableViewController<String, Event> {

    weak var delegate: SimpleEventsViewControllerDelegate?

    class var firstEventKeyPathComparator: KeyPathComparator<Event> {
        return KeyPathComparator(\.hybridType)
    }

    class var sectionKey: (Event) -> String {
        return \.hybridType
    }

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
    var eventsByType: OrderedDictionary<String, [Event]>? = nil {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateDataSource()
        }
    }

    // MARK: - Init

    init(dependencies: Dependencies) {
        super.init(dependencies: dependencies, headerMode: .supplementary)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataSource()
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let dataSource, let event = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.eventSelected(event)
    }

    // MARK: Collection View Data Source

    private func setupDataSource () {
        let cellRegistration = UICollectionView.CellRegistration<EventCollectionViewCell, Event> { cell, indexPath, event in
            cell.contentConfiguration = EventCellContentConfiguration(event: event)
            cell.accessories = [.disclosureIndicator()]
        }
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleCollectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            guard elementKind == UICollectionView.elementKindSectionHeader else { return }
            guard let hybridType = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }

            supplementaryView.text = hybridType
        }

        dataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, event in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: event)
        })
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
        /*
        dataSource.applySnapshotUsingReloadData(snapshot) {
            if self.dataSource.isEmpty {
                self.showNoDataView()
            } else {
                self.hideNoDataView()
            }
        }
        */
    }

}
