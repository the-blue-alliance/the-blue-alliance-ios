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
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        nameLabel.text = viewModel.name
        locationLabel.text = viewModel.location
        dateLabel.text = viewModel.dateString
    }

}
