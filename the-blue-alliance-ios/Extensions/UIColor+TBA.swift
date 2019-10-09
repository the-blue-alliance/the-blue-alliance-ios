import Foundation
import UIKit

extension UIColor {

    public class var primaryBlue: UIColor {
        // TODO: primaryBlue should probably get a high contrast color as well
        let primaryBlue = UIColor.colorWithRGB(rgbValue: 0x3f51b5)
        return dynamicColor(primaryBlue, primaryBlue, UIColor.darkModePrimaryBlue, UIColor.darkModePrimaryBlue)
    }

    private class var darkModePrimaryBlue: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0x5C6BC0) // Muted cool color
    }

    public class var navigationBarTintColor: UIColor {
        return dynamicColor(UIColor.primaryBlue, UIColor.primaryBlue, UIColor.systemGray6, UIColor.systemGray6)
    }

    public class var tableViewHeaderColor: UIColor {
        let lightModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x303F9F)
        return dynamicColor(lightModeDarkBlue, lightModeDarkBlue, UIColor.darkModePrimaryBlue, UIColor.darkModePrimaryBlue)
    }

    public class var segmentedControlSelectedColor: UIColor {
        return dynamicColor(UIColor.primaryBlue, UIColor.primaryBlue, UIColor.white, UIColor.white)
    }

    public class var dangerRed: UIColor {
        // TODO: Take a second pass at these colors
        let dangerRed = UIColor.colorWithRGB(rgbValue: 0xf2dede)
        return dynamicColor(dangerRed, dangerRed, dangerRed, dangerRed)
    }

    public class var dangerDarkRed: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0xa94442)
    }

    public class var googleSignInTextColor: UIColor {
        let lightModeColor = UIColor.color(red: 68, green: 68, blue: 68)
        let darkModeColor = UIColor.white
        return dynamicColor(lightModeColor, lightModeColor, darkModeColor, darkModeColor)
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
