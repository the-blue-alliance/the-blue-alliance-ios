import Foundation
import UIKit

class MyTBATableViewCell: UITableViewCell {

    static let reuseIdentifier = "MyTBACell"
    var myTBAObject: MyTBAEntity? {
        didSet {
            configureCell()
        }
    }
    @IBOutlet private var keyLabel: UILabel!
    @IBOutlet public var backgroundFetchActivityIndicator: UIActivityIndicatorView!

    // MARK: - Private Methods
    
    private func configureCell() {
        keyLabel.text = myTBAObject?.modelKey
    }
    
}
