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

        let htmlString: String = {
            do {
                let htmlString = try NSAttributedString(data: data,
                                                        options: [.documentType: NSAttributedString.DocumentType.html],
                                                        documentAttributes: nil)
                return htmlString.string
            } catch {
                return text
            }
        }()
        subtitleLabel.text = htmlString
    }

}
