//
//  EventCollectionViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAModels

struct EventCellContentConfiguration: UIContentConfiguration, Hashable {

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
        return EventCellContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> EventCellContentConfiguration {
        return self
    }
}

class EventCellContentView: UIView, UIContentView {

    private var currentConfiguration: EventCellContentConfiguration

    var configuration: UIContentConfiguration {
        get {
            return currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? EventCellContentConfiguration else {
                return
            }
            currentConfiguration = newConfiguration
            apply(configuration: currentConfiguration)
        }
    }

    private lazy var nameLabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    private lazy var locationLabel = {
        return UILabel.subheadlineLabel()
    }()
    private lazy var dateLabel = {
        let label = UILabel.subheadlineLabel()
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return label
    }()

    init(configuration: EventCellContentConfiguration) {
        self.currentConfiguration = configuration

        super.init(frame: .zero)

        preservesSuperviewLayoutMargins = true

        setupViews(configuration: currentConfiguration)

        apply(configuration: currentConfiguration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupViews(configuration: EventCellContentConfiguration) {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = .zero
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
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
    private func apply(configuration: EventCellContentConfiguration) {
        nameLabel.text = configuration.name
        locationLabel.text = configuration.location
        dateLabel.text = configuration.dateString
    }
}


class EventCollectionViewCell: UICollectionViewListCell, Reusable {}
