import Foundation
import UIKit

class IconTableViewCell: UITableViewCell, Reusable {

    var viewModel: IconCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconLabel: UILabel!

    // MARK: - View Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.cornerRadius = 8
        iconImageView.clipsToBounds = true
    }

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        iconImageView.image = UIImage(named: viewModel.imageName)
        iconLabel.text = viewModel.name
    }

}
