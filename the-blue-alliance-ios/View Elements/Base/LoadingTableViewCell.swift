import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell, Reusable {

    // MARK: - Reusable

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    // MAKR: - Interface Builder

    @IBOutlet public var keyLabel: UILabel!
    @IBOutlet public var backgroundFetchActivityIndicator: UIActivityIndicatorView!

}
