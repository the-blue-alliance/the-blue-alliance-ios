import Foundation
import UIKit

extension UIBarButtonItem {

    class func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }

}
