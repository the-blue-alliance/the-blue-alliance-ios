import UIKit

class EventTableViewCell: UITableViewCell, Reusable {

    var viewModel: EventCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var weekLabel: EventWeekLabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        nameLabel.text = viewModel.eventShortname
        weekLabel.text = viewModel.eventWeek
        locationLabel.text = viewModel.eventLocation
        dateLabel.text = viewModel.eventDate
    }

}
