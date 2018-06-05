import Foundation
import UIKit

class ReverseSubtitleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ReverseSubtitleCell"

    @IBOutlet public var titleLabel: UILabel! {
        didSet {
            titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.textColor = UIColor.darkGray
        }
    }
    @IBOutlet public var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
            subtitleLabel.adjustsFontForContentSizeCategory = true
            subtitleLabel.textColor = UIColor.black
        }
    }

    public func setHTMLSubtitle(text: String) {
        guard let data = text.data(using: String.Encoding.unicode) else { return }

        let htmlString = try! NSAttributedString(data: data,
                                                 options: [.documentType: NSAttributedString.DocumentType.html],
                                                 documentAttributes: nil)
        subtitleLabel.text = htmlString.string
    }

}
