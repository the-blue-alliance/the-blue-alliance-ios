import Foundation
import UIKit

class TeamTableViewCell: UITableViewCell, Reusable {

    var viewModel: TeamCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
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
        nameLabel.text = viewModel.nickname
        locationLabel.text = viewModel.location
    }
}
