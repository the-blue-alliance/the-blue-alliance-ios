//
//  EventCollectionViewListCell.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAAPI // TODO: We can move this out to an extension somewhere that joins these...

struct EventListContentConfiguration: UIContentConfiguration {

    var name: String?
    var location: String?
    var dateString: String?

    init(event: Event) {
        name = event.displayName
        location = event.displayLocation
        dateString = event.displayDates
    }

    fileprivate var separatorLayoutGuide: UILayoutGuide?

    func makeContentView() -> any UIView & UIContentView {
        return EventListContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> EventListContentConfiguration {
        return self
    }
}

private class EventListContentView: UIView, UIContentView {

    private var currentConfiguration: EventListContentConfiguration

    var configuration: UIContentConfiguration {
        get {
            return currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? EventListContentConfiguration else {
                fatalError("EventListContentView expect configuration be a EventListContentConfiguration")
            }
            currentConfiguration = newConfiguration
            apply(configuration: currentConfiguration)
        }
    }

    private lazy var nameLabel = {
        return UILabel.bodyLabel()
    }()
    private lazy var locationLabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var dateLabel = {
        let label = UILabel.subheadlineLabel()
        label.textColor = .secondaryLabel
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return label
    }()

    init(configuration: EventListContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        setupViews()

        apply(configuration: currentConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupViews() {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = .zero
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor),
        ])

        stackView.addArrangedSubview(nameLabel)

        let detailStackView = UIStackView()
        detailStackView.axis = .horizontal
        detailStackView.distribution = .fill
        detailStackView.alignment = .fill
        detailStackView.addArrangedSubview(locationLabel)
        detailStackView.addArrangedSubview(dateLabel)

        stackView.addArrangedSubview(detailStackView)
    }

    @MainActor
    private func apply(configuration: EventListContentConfiguration) {
        nameLabel.text = configuration.name
        nameLabel.isHidden = configuration.name == nil

        locationLabel.text = configuration.location
        locationLabel.isHidden = configuration.location == nil

        dateLabel.text = configuration.dateString
        dateLabel.isHidden = configuration.dateString == nil
    }
}


class EventCollectionViewListCell: UICollectionViewListCell {}
