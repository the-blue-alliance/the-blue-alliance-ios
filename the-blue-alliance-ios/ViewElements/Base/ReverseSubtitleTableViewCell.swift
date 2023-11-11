import Foundation
import UIKit

class ReverseSubtitleTableViewCell: UITableViewCell, Reusable {

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        selectionStyle = .none
    }

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MARK: - Interface Builder

    @IBOutlet public var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.textColor = UIColor.secondaryLabel
        }
    }
    @IBOutlet public var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
            subtitleLabel.adjustsFontForContentSizeCategory = true
            subtitleLabel.textColor = UIColor.label
        }
    }

}
