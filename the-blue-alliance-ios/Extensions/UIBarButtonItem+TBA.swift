import Foundation
import UIKit

extension UIBarButtonItem {

    class func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }

}
