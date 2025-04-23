//
//  TBAFakeTableViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

class TBAFakeTableViewController<Section: Hashable, Item: Hashable>: TBACollectionViewController<Section, Item> {

    static var emptySupplementaryViewProvider: (_ collectionView: UICollectionView, _ elementKind: String, _ indexPath: IndexPath) -> UICollectionReusableView? {
        // Return the closure from the computed property's getter
        return { _, _, _ in
            return nil
        }
    }

    init(dependencies: Dependencies, headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none) {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = UIColor.systemGroupedBackground
        config.headerMode = headerMode
        config.headerTopPadding = .zero
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)

        super.init(collectionViewLayout: collectionViewLayout, dependencies: dependencies)
    }

    override init(collectionViewLayout: UICollectionViewLayout, dependencies: Dependencies) {
        super.init(collectionViewLayout: collectionViewLayout, dependencies: dependencies)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
