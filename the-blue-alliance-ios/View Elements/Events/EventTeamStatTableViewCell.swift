import UIKit

class EventTeamStatTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventTeamStatCell"

    var viewModel: EventTeamStatCellViewModel? {
        didSet {
            configureCell()
        }
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
