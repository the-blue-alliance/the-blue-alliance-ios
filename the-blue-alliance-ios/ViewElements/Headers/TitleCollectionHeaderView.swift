//
//  TitleCollectionHeaderView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/21/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

class TitleCollectionHeaderView: UICollectionReusableView, Reusable {

    @MainActor var text: String? {
        didSet {
            textLabel.text = text
        }
    }

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()

        textLabel.text = text
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupViews() {
        backgroundColor = UIColor.tableViewHeaderColor

        addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            // TODO: I think to get this to match table view, we make this a >= constraint
            // The content should collapse in itself
            textLabel.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -8),
            textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])
        // headerTitleLabel.autoPinEdgesToSuperviewEdges(with: .init(top: 8, left: 8, bottom: 8, right: 8))
    }

    // MARK: - Reuse

    @MainActor
    override func prepareForReuse() {
        super.prepareForReuse()

        textLabel.text = nil
    }

}
