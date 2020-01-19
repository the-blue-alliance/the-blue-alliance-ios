import UIKit

extension NSDiffableDataSourceSnapshot {

    mutating func insertSection(_ identifier: SectionIdentifierType, atIndex index: Int) {
        if index < 0 {
            fatalError("insertSection must be called with a positive index")
        }

        if sectionIdentifiers.contains(identifier) {
            guard let oldIndex = indexOfSection(identifier) else {
                fatalError("Section exists but doesn't have an index")
            }
            if oldIndex == index {
                return
            }
            if sectionIdentifiers.count <= index {
                // Move items previously in section
                let section = sectionIdentifiers[oldIndex]
                let items = itemIdentifiers(inSection: section)
                deleteSections([identifier])
                appendSections([identifier])
                appendItems(items, toSection: identifier)
            } else {
                let section = sectionIdentifiers[index]
                moveSection(identifier, beforeSection: section)
            }
        } else if sectionIdentifiers.count <= index {
            appendSections([identifier])
        } else {
            let section = sectionIdentifiers[index]
            insertSections([identifier], beforeSection: section)
        }
    }

    mutating func insertItem(_ identifier: ItemIdentifierType, inSection section: SectionIdentifierType, atIndex index: Int) {
        if index < 0 {
            fatalError("insertItem must be called with a positive index")
        }

        let items = itemIdentifiers(inSection: section)
        if items.contains(identifier) {
            guard let oldIndex = items.firstIndex(of: identifier) else {
                fatalError("Item exists in section but doesn't have an index")
            }
            if oldIndex == index {
                return
            }
            if items.count <= index {
                deleteItems([identifier])
                appendItems([identifier], toSection: section)
            } else {
                let item = items[index]
                moveItem(identifier, beforeItem: item)
            }
        } else {
            if items.count <= index {
                appendItems([identifier], toSection: section)
            } else {
                let item = items[index]
                insertItems([identifier], beforeItem: item)
            }
        }
    }

}
