import UIKit

extension UIDevice {

    public static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    public static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

}
