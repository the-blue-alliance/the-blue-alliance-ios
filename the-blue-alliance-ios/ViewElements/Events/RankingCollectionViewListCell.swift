//
//  RankingCollectionViewListCell.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/22/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAAPI // TODO: Move this into an extension...

struct RankingListContentConfiguration: UIContentConfiguration {

    var teamNumber: String?
    var rank: Int?
    var wlt: String?
    var teamName: String?
    var detailText: String?

    init(districtRanking: DistrictRanking) {
        teamNumber = districtRanking.teamNumber
        rank = districtRanking.rank
        detailText = "\(districtRanking.pointTotal) Points"
    }

    // MARK: - UIContentConfiguration

    func makeContentView() -> any UIView & UIContentView {
        return RankingListContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> RankingListContentConfiguration {
        return self
    }

}

private class RankingListContentView: UIView, UIContentView {

    // MARK: - UIContentView

    private var currentConfiguration: RankingListContentConfiguration

    var configuration: UIContentConfiguration {
        get {
            return currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? RankingListContentConfiguration else {
                fatalError("RankingListContentView expect configuration be a RankingListContentConfiguration")
            }
            currentConfiguration = newConfiguration
            apply(configuration: currentConfiguration)
        }
    }

    // MARK: - Views

    private let numberLabel: UILabel = {
        let label = UILabel.bodyLabel()
        label.setContentHuggingPriority(.defaultHigh + 2, for: .horizontal) // horizontalHuggingPriority 252
        return label
    }()

    private let rankLabel: UILabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .secondaryLabel
        return label
    }()

    private let wltLabel: UILabel = {
        let label = UILabel.bodyLabel()
        label.textColor = .highlightColor
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal) // horizontalHuggingPriority 251
        label.setContentHuggingPriority(.defaultLow + 1, for: .vertical) // verticalHuggingPriority 251
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel.bodyLabel()
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal) // horizontalHuggingPriority 251
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal) // horizontalHuggingPriority 251
        label.setContentHuggingPriority(.defaultLow + 1, for: .vertical) // verticalHuggingPriority 251
        return label
    }()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        stackView.distribution = .fill
        return stackView
    }()

    // MARK: - Initialization

    init(configuration: RankingListContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        setupViews()
        setupConstraints()

        apply(configuration: currentConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        // Add labels to their respective vertical stack views
        leftStackView.addArrangedSubview(numberLabel)
        leftStackView.addArrangedSubview(rankLabel)
        leftStackView.addArrangedSubview(wltLabel)

        rightStackView.addArrangedSubview(nameLabel)
        rightStackView.addArrangedSubview(detailLabel)

        // Add vertical stack views to the main horizontal stack view
        mainStackView.addArrangedSubview(leftStackView)
        mainStackView.addArrangedSubview(rightStackView)

        // Add the main stack view to the content view
        addSubview(mainStackView) // Add to the content view itself (which is this UIView subclass)
    }

    private func setupConstraints() {
        // Constraints for the mainStackView pinned to the content view
        // Using constants based on the XIB
        let leftStackViewWidth: CGFloat = 68 // Fixed width from XIB

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor),

            // Constraint for the fixed width of the leftStackView
            leftStackView.widthAnchor.constraint(equalToConstant: leftStackViewWidth),

            // Baseline alignment constraint between numberLabel and nameLabel
            numberLabel.firstBaselineAnchor.constraint(equalTo: nameLabel.firstBaselineAnchor)
        ])
    }


    // MARK: - Apply Configuration

    private func apply(configuration: RankingListContentConfiguration) {
        numberLabel.text = configuration.teamNumber
        numberLabel.isHidden = configuration.teamNumber == nil

        if let rank = configuration.rank {
            rankLabel.text = "Rank \(rank)"
        } else {
            rankLabel.text = nil
        }
        rankLabel.isHidden = configuration.rank == nil

        if let wlt = configuration.wlt {
            wltLabel.text = wlt
        } else {
            wltLabel.text = nil
        }
        wltLabel.isHidden = configuration.wlt == nil

        nameLabel.text = configuration.teamName
        nameLabel.isHidden = configuration.teamName == nil

        detailLabel.text = configuration.detailText
        detailLabel.isHidden = configuration.detailText == nil
    }
}

class RankingCollectionViewListCell: UICollectionViewListCell {}
