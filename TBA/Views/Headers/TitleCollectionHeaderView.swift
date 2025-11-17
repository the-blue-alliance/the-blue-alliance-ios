//
//  TitleCollectionHeaderView.swift
//  TBA
//
//  Created by Zachary Orr on 4/21/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

class TitleCollectionHeaderView: UICollectionReusableView, Reusable {
    @MainActor var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .white
        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .tableViewHeaderColor

        setupViews()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupViews() {
        addSubview(titleLabel)

        // Magic number - because it's been 5 for a decade, and I like the way it looks at 5
        let verticalSpacing = 5.0

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: verticalSpacing),
            titleLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -verticalSpacing),
        ])
    }
}
