//
//  EventCollectionViewCell.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAModels

// TODO: UIBackgroundConfiguration

struct EventCellContentConfiguration: UIContentConfiguration, Hashable {

    var name: String
    var location: String?
    var dateString: String?

    init(event: Event) {
        name = event.displayShortName
        location = event.displayLocation
        dateString = event.displayDates
    }

    init(name: String, location: String?, dateString: String?) {
        self.name = name
        self.location = location
        self.dateString = dateString
    }

    func makeContentView() -> any UIView & UIContentView {
        return EventCellContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> EventCellContentConfiguration {
        return self
    }
}

class EventCellContentView: UIView, UIContentView {

    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }

    private lazy var nameLabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .body)
        return label
    }()
    // TODO: DRY these...
    private lazy var locationLabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var dateLabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        return label
    }()

    init(configuration: EventCellContentConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        // Create the content view UI
        setupAllViews()

        // Apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @MainActor
    private func setupAllViews() {
        let stackView = UIStackView(forAutoLayout: ())
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = .zero
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: .init(top: 8, left: 16, bottom: 8, right: 8))

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
    private func apply(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? EventCellContentConfiguration else {
            return
        }

        nameLabel.text = configuration.name
        locationLabel.text = configuration.location
        dateLabel.text = configuration.dateString
    }
}


class EventCollectionViewCell: UICollectionViewListCell, Reusable {}
