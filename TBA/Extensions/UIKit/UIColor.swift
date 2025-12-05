import Foundation
import UIKit

// TODO: Eventually we should deprecate all these old UIColor models
// Currently they're still in the app because we can't get all these
// colors using the SwiftUI Color (like systemGrey5)
// We need to pick new colors, but these colors were agonized over
// during the dark mode update, and I don't want to settle for just-okay.
public extension UIColor {
    // MARK: - Internal Colors

    private class var primaryYellow: UIColor {
        UIColor.colorWithRGB(rgbValue: 0xFFC107)
    }

    private class var primaryYellowHighContrast: UIColor {
        UIColor.colorWithRGB(rgbValue: 0xFFD54F)
    }

    private class var darkModePrimaryBlue: UIColor {
        let lightModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x303F9F)
        let lightModeDarkBlueHighContrast = UIColor.colorWithRGB(rgbValue: 0x283593)
        let darkModeDarkBlue = UIColor.colorWithRGB(rgbValue: 0x3F51B5)
        let darkModeDarkBlueHighContrast = UIColor.colorWithRGB(rgbValue: 0x5C6BC0)
        return dynamicColor(lightModeDarkBlue, lightModeDarkBlueHighContrast, darkModeDarkBlue, darkModeDarkBlueHighContrast)
    }

    // MARK: Safe Colors - support light/dark mode, high contrast

    class var primaryBlue: UIColor {
        let lightModePrimaryBlue = UIColor.colorWithRGB(rgbValue: 0x3F51B5)
        let lightModePrimaryBlueHighContrast = UIColor.colorWithRGB(rgbValue: 0x3949AB)
        let darkModePrimaryBlue = UIColor.colorWithRGB(rgbValue: 0x5C6BC0)
        let darkModePrimaryBlueHighContrast = UIColor.colorWithRGB(rgbValue: 0x7986CB)
        return dynamicColor(lightModePrimaryBlue, lightModePrimaryBlueHighContrast, darkModePrimaryBlue, darkModePrimaryBlueHighContrast)
    }

    class var highlightColor: UIColor {
        dynamicColor(UIColor.primaryBlue, UIColor.primaryBlue, UIColor.primaryYellow, UIColor.primaryYellowHighContrast)
    }

    class var navigationBarTintColor: UIColor {
        dynamicColor(UIColor.primaryBlue, UIColor.primaryBlue, UIColor.systemGray6, UIColor.systemGray6)
    }

    class var tabBarTintColor: UIColor {
        dynamicColor(UIColor.systemBlue, UIColor.systemBlue, UIColor.primaryYellow, UIColor.primaryYellowHighContrast)
    }

    class var tableViewHeaderColor: UIColor {
        dynamicColor(UIColor.darkModePrimaryBlue, UIColor.darkModePrimaryBlue, UIColor.systemGray5, UIColor.systemGray5)
    }

    class var segmentedControlSelectedColor: UIColor {
        dynamicColor(UIColor.primaryBlue, UIColor.primaryBlue, UIColor.white, UIColor.white)
    }

    class var yearSelectColor: UIColor {
        dynamicColor(UIColor.white, UIColor.white, UIColor.systemGray5, UIColor.systemGray5)
    }

    // NOTE: Match Summary Background Colors don't really follow "high contrast" guidelines - they're used to color block information,
    // so instead of creating a higher contrast with the text they're used with, they're higher value colors to create a better contrast
    // between each otehr.

    class var redAllianceBackgroundColor: UIColor {
        let lightModeColor = UIColor.colorWithRGB(rgbValue: 0xFFEEEE)
        let lightModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0xFFDDDD)
        let darkModeColor = UIColor.colorWithRGB(rgbValue: 0x660000)
        let darkModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0x770000)
        return dynamicColor(lightModeColor, lightModeHighContrastColor, darkModeColor, darkModeHighContrastColor)
    }

    class var redAllianceScoreBackgroundColor: UIColor {
        let lightModeColor = UIColor.colorWithRGB(rgbValue: 0xFFDDDD)
        let lightModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0xFFCCCC)
        let darkModeColor = UIColor.colorWithRGB(rgbValue: 0x770000)
        let darkModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0x880000)
        return dynamicColor(lightModeColor, lightModeHighContrastColor, darkModeColor, darkModeHighContrastColor)
    }

    class var blueAllianceBackgroundColor: UIColor {
        let lightModeColor = UIColor.colorWithRGB(rgbValue: 0xEEEEFF)
        let lightModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0xDDDDFF)
        let darkModeColor = UIColor.colorWithRGB(rgbValue: 0x000066)
        let darkModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0x000077)
        return dynamicColor(lightModeColor, lightModeHighContrastColor, darkModeColor, darkModeHighContrastColor)
    }

    class var blueAllianceScoreBackgroundColor: UIColor {
        let lightModeColor = UIColor.colorWithRGB(rgbValue: 0xDDDDFF)
        let lightModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0xCCCCFF)
        let darkModeColor = UIColor.colorWithRGB(rgbValue: 0x000088)
        let darkModeHighContrastColor = UIColor.colorWithRGB(rgbValue: 0x0000AA)
        return dynamicColor(lightModeColor, lightModeHighContrastColor, darkModeColor, darkModeHighContrastColor)
    }

    class var avatarRed: UIColor {
        .colorWithRGB(rgbValue: 0xDA3434)
    }

    class var avatarBlue: UIColor {
        .colorWithRGB(rgbValue: 0x487FCC)
    }

    class var dangerRed: UIColor {
        let dangerRed = UIColor.colorWithRGB(rgbValue: 0xF2DEDE)
        return dynamicColor(dangerRed, dangerRed, dangerRed, dangerRed)
    }

    class var dangerDarkRed: UIColor {
        let dangerDarkRed = UIColor.colorWithRGB(rgbValue: 0xA94442)
        return dynamicColor(dangerDarkRed, dangerDarkRed, dangerDarkRed, dangerDarkRed)
    }

    class var myTBAStarColor: UIColor {
        UIColor.colorWithRGB(rgbValue: 0xFFC108)
    }

    class var googleSignInTextColor: UIColor {
        let lightModeColor = UIColor.color(red: 68, green: 68, blue: 68)
        let darkModeColor = UIColor.white
        return dynamicColor(lightModeColor, lightModeColor, darkModeColor, darkModeColor)
    }

    // MARK: - Match Breakdown Colors

    class var nullHatchPanelColor: UIColor {
        .colorWithRGB(rgbValue: 0x555555)
    }

    class var hatchPanelColor: UIColor {
        .colorWithRGB(rgbValue: 0xF4D941)
    }

    class var cargoColor: UIColor {
        .colorWithRGB(rgbValue: 0xFFA500)
    }

    // MARK: - Private Methods

    private static func dynamicColor(_ lightMode: UIColor, _ lightModeHighContrast: UIColor, _ darkMode: UIColor, _ darkModeHighContrast: UIColor) -> UIColor {
        UIColor { (traitCollection: UITraitCollection) -> UIColor in
            switch (traitCollection.userInterfaceStyle,
                    traitCollection.accessibilityContrast)
            {
            case (.dark, .high): return darkModeHighContrast
            case (.dark, _): return darkMode
            case (_, .high): return lightModeHighContrast
            default: return lightMode
            }
        }
    }

    private static func color(red: Double, green: Double, blue: Double) -> UIColor {
        UIColor(red: CGFloat(red / 255.0), green: CGFloat(green / 255.0), blue: CGFloat(blue / 255.0), alpha: 1.0)
    }

    private static func colorWithRGB(rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
