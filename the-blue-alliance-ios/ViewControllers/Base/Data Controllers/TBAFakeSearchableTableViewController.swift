//
//  TBAFakeSearchableTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

class TBAFakeSearchableTableViewController<Section: Hashable, Item: Hashable>: TBAFakeTableViewController<Section, Item>, SearchableController, UISearchResultsUpdating {

    let searchBar = UISearchBar()

    init(dependencies: Dependencies) {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = UIColor.systemGroupedBackground
        config.headerMode = .supplementary
        config.headerTopPadding = 0.0
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)

        super.init(collectionViewLayout: collectionViewLayout, dependencies: dependencies)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerReusableSupplementaryView(elementKind: UICollectionView.elementKindSectionHeader, SearchHeaderView.self)
    }

    @MainActor
    func updateDataSource() {
        fatalError("Implement updateDataSource in subclass")
    }

    // MARK: - UISearchResultsUpdating

    public func updateSearchResults(for searchController: UISearchController) {
        updateDataSource()
    }

}

class SearchHeaderView: UICollectionReusableView, Reusable {
    // TODO: Needs a search bar
}
