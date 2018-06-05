import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell {

    static let reuseIdentifier = "LoadingCell"

    @IBOutlet public var keyLabel: UILabel!
    @IBOutlet public var backgroundFetchActivityIndicator: UIActivityIndicatorView!

}
