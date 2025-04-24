//
//  TBACollectionViewListController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import UIKit

class TBACollectionViewListController<Cell: UICollectionViewCell & Reusable, Item: Hashable>: TBACollectionViewController<Cell, Item> {

    init(headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none) {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .systemGroupedBackground
        config.headerMode = headerMode
        config.headerTopPadding = .zero
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: config)

        super.init(collectionViewLayout: collectionViewLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
