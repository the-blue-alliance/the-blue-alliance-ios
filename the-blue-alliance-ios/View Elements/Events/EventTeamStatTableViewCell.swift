import UIKit

class EventTeamStatTableViewCell: UITableViewCell, Reusable {

    var viewModel: EventTeamStatCellViewModel? {
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
    @IBOutlet private weak var statLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        nameLabel.text = viewModel.statName
        statLabel.text = viewModel.statValue
    }

}
