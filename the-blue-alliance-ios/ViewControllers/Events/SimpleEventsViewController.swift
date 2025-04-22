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

//extension SimpleEventsViewControllerDelegate {
//    func title(for event: Event) -> String? {
//        return nil
//    }
//}

protocol SimpleEventsViewControllerDataSourceConfiguration {
    var firstKeyPathComparator: KeyPathComparator<Event> { get }
    var groupingKeyForValue: (Event) -> String { get }
}

class SimpleEventsViewController: TBAFakeTableViewController, SimpleEventsViewControllerDataSourceConfiguration {

    var firstKeyPathComparator: KeyPathComparator<Event> {
        return KeyPathComparator(\.hybridType)
    }

    var groupingKeyForValue: (Event) -> String {
        return \.hybridType
    }

    weak var delegate: SimpleEventsViewControllerDelegate?

    private var dataSource: CollectionViewDataSource<String, Event>!
    var events: [Event]? = nil {
        didSet {
            guard var events else {
                return
            }
            events = events.sorted(using: [
                firstKeyPathComparator,
                KeyPathComparator(\.startDate),
                KeyPathComparator(\.name)
            ])
            eventsByType = OrderedDictionary(grouping: events, by: groupingKeyForValue)
            updateDataSource()
        }
    }
    var eventsByType: OrderedDictionary<String, [Event]>? = nil

    init(dependencies: Dependencies) {
        super.init(dependencies: dependencies, headerMode: .supplementary)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableCell(EventCollectionViewCell.self)

        collectionView.dataSource = dataSource
        setupDataSource()
    }

    // MARK: UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let event = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.eventSelected(event)
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    // MARK: Collection View Data Source

    private func setupDataSource () {
        // TODO: Something like this...
        let cellRegistration = UICollectionView.CellRegistration<EventCollectionViewCell, Event> { cell, indexPath, event in
            var contentConfiguration = EventCellContentConfiguration(event: event)
            // contentConfiguration.event = event
            cell.contentConfiguration = EventCellContentConfiguration(event: event)
            cell.accessories = [.disclosureIndicator()]
        }

        dataSource = CollectionViewDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, event in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: event)
        })
        dataSource.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let headerView = collectionView.dequeueReusableSupplementaryView(elementKind: UICollectionView.elementKindSectionHeader, indexPath: indexPath) as TitleCollectionHeaderView

            if let event = self.dataSource.itemIdentifier(for: indexPath) {
                headerView.configure(with: self.delegate?.title(for: event))
            }

            return headerView
        }
        // dataSource.statefulDelegate = self
    }

    @MainActor private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        if let eventsByType {
            snapshot.appendSections(eventsByType.keys.elements)
            for (section, events) in eventsByType {
                snapshot.appendItems(events, toSection: section)
            }
        }
        dataSource.applySnapshotUsingReloadData(snapshot)
    }

    // Handles context menu presentation (long-press)
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {

        guard let indexPath = indexPaths.first, // Get the first selected item's index path
              let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil // No item found at the index path
        }

        let configuration = UIContextMenuConfiguration(identifier: item.key as NSCopying, previewProvider: nil) { _ in

            // Create actions for the context menu
            let printTitleAction = UIAction(title: "Print Title", image: UIImage(systemName: "printer")) { _ in
                print("Context Menu Action: Print Title for \(item.name)")
                // Perform the action (e.g., log, trigger a print job, etc.)
            }

            // You could add other actions here, like:
            // let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            //     print("Context Menu Action: Delete for \(item.title)")
            //     self.deleteItem(item)
            // }

            // Create a menu with the actions
            return UIMenu(title: "", children: [printTitleAction]) // Use children for a flat list of actions
            // Or for submenus: return UIMenu(title: "Options", children: [someAction, UIMenu(title: "More", children: [anotherAction])])
        }

        return configuration
    }

    // Optional: Customize the preview when the context menu is presented
    /*
     override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
     guard let identifier = configuration.identifier as? UUID,
     let indexPath = dataSource.indexPath(for: ListItem(id: identifier, title: "")), // Note: Requires ListItem to be Equatable if title is not used
     let cell = collectionView.cellForItem(at: indexPath) else {
     return nil
     }

     let parameters = UIPreviewParameters()
     // Customize parameters if needed (e.g., backgroundColor, visiblePath)
     // parameters.backgroundColor = .systemGray6

     return UITargetedPreview(view: cell, parameters: parameters)
     }
     */

    // Optional: Customize the preview when the context menu is dismissed
    /*
     override func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
     guard let identifier = configuration.identifier as? UUID,
     let indexPath = dataSource.indexPath(for: ListItem(id: identifier, title: "")), // Note: Requires ListItem to be Equatable if title is not used
     let cell = collectionView.cellForItem(at: indexPath) else {
     return nil
     }

     let parameters = UIPreviewParameters()
     // Customize parameters if needed
     // parameters.backgroundColor = .systemGray6

     return UITargetedPreview(view: cell, parameters: parameters)
     }
     */

}
