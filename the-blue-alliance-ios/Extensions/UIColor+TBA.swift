import Foundation
import UIKit

extension UIColor {

    public class var primaryBlue: UIColor {
        return .colorWithRGB(rgbValue: 0x3f51b5)
    }

    public class var primaryDarkBlue: UIColor {
        return .color(red: 48, green: 63, blue: 159)
    }

    public class var dangerRed: UIColor {
        return .colorWithRGB(rgbValue: 0xf2dede)
    }

    public class var dangerDarkRed: UIColor {
        return .colorWithRGB(rgbValue: 0xa94442)
    }

    public class var backgroundGray: UIColor {
        return .color(red: 239, green: 239, blue: 239)
    }

    class func color(red: Double, green: Double, blue: Double) -> UIColor {
        return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1.0)
    }

    class func colorWithRGB(rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
