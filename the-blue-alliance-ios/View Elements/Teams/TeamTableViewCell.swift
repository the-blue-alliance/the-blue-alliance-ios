import Foundation
import UIKit

class TeamTableViewCell: UITableViewCell {
    static let reuseIdentifier = "TeamCell"

    var viewModel: TeamCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        numberLabel.text = viewModel.teamNumber
        nameLabel.text = viewModel.teamNickname
        locationLabel.text = viewModel.teamLocation
    }
}
