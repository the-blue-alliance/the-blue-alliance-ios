import UIKit

class EventTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventCell"

    var viewModel: EventCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        nameLabel.text = viewModel.eventShortname
        locationLabel.text = viewModel.eventLocation
        dateLabel.text = viewModel.eventDate
    }

}
