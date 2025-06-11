//
//  TeamCollectionViewListCell.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/25/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAAPI // TODO: We can move this out to an extension somewhere that joins these...


@MainActor private let fontToTeamNumberWidthCache: NSCache<UIFont, NSNumber> = {
    let cache = NSCache<UIFont, NSNumber>()
    // TODO: Can configure the cache stuff but yolo
    return cache
}()

struct TeamListContentConfiguration: UIContentConfiguration {

    var teamNumber: String?
    var name: String?
    var location: String?

    var teamNumberFont: UIFont = .preferredFont(forTextStyle: .headline)

    init(team: Team) {
        teamNumber = String(team.teamNumber)
        name = team.nickname
        location = team.locationString
    }

    func makeContentView() -> any UIView & UIContentView {
        return TeamListContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> TeamListContentConfiguration {
        return self
    }
}

private class TeamListContentView: UIView, UIContentView {

    private var currentConfiguration: TeamListContentConfiguration

    var configuration: UIContentConfiguration {
        get {
            return currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? TeamListContentConfiguration else {
                fatalError("TeamListContentView expect configuration be a TeamListContentConfiguration")
            }
            currentConfiguration = newConfiguration
            apply(configuration: currentConfiguration)
        }
    }

    let numberLabel: UILabel = {
        let label = UILabel.headlineLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        // label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    var numberLabelWidthConstraint: NSLayoutConstraint!

    let nameLabel: UILabel = {
        let label = UILabel.bodyLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel.subheadlineLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        // label.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()

    private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        return stackView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()

    init(configuration: TeamListContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        setupViews()
        setupConstraints(configuration: currentConfiguration)

        apply(configuration: currentConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupViews() {
        verticalStackView.addArrangedSubview(nameLabel)
        verticalStackView.addArrangedSubview(locationLabel)

        horizontalStackView.addArrangedSubview(numberLabel)
        horizontalStackView.addArrangedSubview(verticalStackView)

        mainStackView.addArrangedSubview(horizontalStackView)

        addSubview(mainStackView)
    }

    private func setupConstraints(configuration: TeamListContentConfiguration) {
        updateTeamNumberLabel(configuration: configuration)

        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor)
        ])
    }

    private func updateTeamNumberLabel(configuration: TeamListContentConfiguration) {
        if let width = fontToTeamNumberWidthCache.object(forKey: configuration.teamNumberFont) {
            updateTeamNumberLabel(width: CGFloat(width.floatValue))
        } else {
            let width = configuration.teamNumberFont.widthForTeamMaxTeamNumber()
            fontToTeamNumberWidthCache.setObject(NSNumber(value: width), forKey: configuration.teamNumberFont)
            updateTeamNumberLabel(width: width)
        }
    }

    private func updateTeamNumberLabel(width: CGFloat) {
        if numberLabelWidthConstraint == nil {
            numberLabel.translatesAutoresizingMaskIntoConstraints = false
            numberLabelWidthConstraint = numberLabel.widthAnchor.constraint(equalToConstant: width)
            numberLabelWidthConstraint.isActive = true
        } else {
            numberLabelWidthConstraint.constant = width
        }
    }

    @MainActor
    private func apply(configuration: TeamListContentConfiguration) {
        numberLabel.font = configuration.teamNumberFont
        numberLabel.text = configuration.teamNumber
        numberLabel.isHidden = configuration.teamNumber == nil

        nameLabel.text = configuration.name
        nameLabel.isHidden = configuration.name == nil

        locationLabel.text = configuration.location
        locationLabel.isHidden = configuration.location == nil

        updateTeamNumberLabel(configuration: configuration)
    }
}


class TeamCollectionViewListCell: UICollectionViewListCell {}
