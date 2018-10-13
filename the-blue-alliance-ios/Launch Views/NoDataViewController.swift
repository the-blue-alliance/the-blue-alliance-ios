import Foundation
import UIKit

class NoDataViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!

    init() {
        super.init(nibName: "NoDataView", bundle: nil)

        view.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
