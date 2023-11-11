import Foundation
import UIKit

class RankingTableViewCell: UITableViewCell, Reusable {

    var viewModel: RankingCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var rankLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var wltLabel: UILabel! {
        didSet {
            wltLabel.textColor = UIColor.highlightColor
        }
    }
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
