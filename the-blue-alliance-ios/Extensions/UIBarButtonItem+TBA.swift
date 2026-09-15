import Foundation
import UIKit

extension UIBarButtonItem {

    class func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        return UIBarButtonItem(customView: activityIndicatorView)
    }

    /// Wraps a menu button for the bar without the bar's own glass capsule around it, which
    /// would otherwise draw a second ring outside the button's.
    convenience init(pill: UIButton) {
        self.init(customView: pill)
        hidesSharedBackground = true
    }

}
