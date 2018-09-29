import Foundation
import UIKit

class RankingTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RankingCell"

    var viewModel: RankingCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var wltLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        rankLabel.isHidden = !viewModel.hasRank
        rankLabel.text = viewModel.rankText

        numberLabel.text = viewModel.teamNumber
        nameLabel.text = viewModel.teamName

        detailLabel.isHidden = !viewModel.hasDetails
        detailLabel.text = viewModel.detailText

        wltLabel.isHidden = !viewModel.hasWLT
        wltLabel.text = viewModel.wltText
    }

}
