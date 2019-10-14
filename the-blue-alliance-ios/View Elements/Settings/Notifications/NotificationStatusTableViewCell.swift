import Foundation
import UIKit

class NotificationStatusTableViewCell: UITableViewCell {

    var viewModel: NotificationStatusCellViewModel? {
        didSet {
            configureCell()
        }
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var statusImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Private Methods

    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }

        titleLabel.alpha = 1.0
        titleLabel.text = viewModel.title
        statusImageView.image = nil
        activityIndicator.isHidden = true

        selectionStyle = .none
        isUserInteractionEnabled = false
        accessoryType = .none

        switch viewModel.notificationStatus {
        case .unknown:
            titleLabel.alpha = 0.5
        case .loading:
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        case .valid:
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            statusImageView.tintColor = UIColor.primaryBlue
        case .invalid:
            selectionStyle = .default
            accessoryType = .disclosureIndicator
            isUserInteractionEnabled = true
            statusImageView.image = UIImage(systemName: "xmark.circle.fill")
            statusImageView.tintColor = UIColor.systemRed
        }
    }

}
