import Foundation
import UIKit

class NoDataViewController: UIViewController {

    var noDataText: String? {
        didSet {
            textLabel.text = noDataText
        }
    }

    @IBOutlet private weak var textLabel: UILabel!

    init() {
        super.init(nibName: "NoDataView", bundle: nil)

        view.backgroundColor = UIColor.clear
        textLabel.textColor = UIColor.systemGray
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
