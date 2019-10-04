import Foundation
import UIKit

extension UIColor {

    public class var primaryBlue: UIColor {
        let primaryBlue = UIColor.colorWithRGB(rgbValue: 0x3f51b5)
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch(traitCollection.userInterfaceStyle,
                   traitCollection.accessibilityContrast)
            {
                case (.dark, .high): return primaryBlue // A200
                case (.dark, _):     return UIColor.systemGray6
                case (_, .high):     return primaryBlue // ~A600
                default:             return UIColor.colorWithRGB(rgbValue: 0x3f51b5) // 500
            }
        }
    }

    public class var darkBlue: UIColor {
        let lightModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x303F9F)
        let darkModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x5C6BC0) // Muted cool color
        // let darkModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x283593)
        return dynamicColor(lightModeDarkBlue, lightModeDarkBlue, darkModeDarkBlue, darkModeDarkBlue)
    }

    public class var dangerRed: UIColor {
        let dangerRed = UIColor.colorWithRGB(rgbValue: 0xf2dede)
        return dynamicColor(dangerRed, dangerRed, dangerRed, dangerRed)
    }

    public class var dangerDarkRed: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0xa94442)
    }

    // TODO: private
    public static func dynamicColor(_ lightMode: UIColor, _ lightModeHighContrast: UIColor, _ darkMode: UIColor, _ darkModeHighContrast: UIColor) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch(traitCollection.userInterfaceStyle,
                   traitCollection.accessibilityContrast)
            {
                case (.dark, .high): return darkModeHighContrast
                case (.dark, _):     return darkMode
                case (_, .high):     return lightModeHighContrast
                default:             return lightMode
            }
        }
    }

    private static func color(red: Double, green: Double, blue: Double) -> UIColor {
        return UIColor(red: CGFloat(red/255.0), green: CGFloat(green/255.0), blue: CGFloat(blue/255.0), alpha: 1.0)
    }

    private static func colorWithRGB(rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
