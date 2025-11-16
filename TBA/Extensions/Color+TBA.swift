//
//  Color+TBA.swift
//  TBA
//
//  Created by Zachary Orr on 8/15/24.
//

import SwiftUI

extension ShapeStyle where Self == Color {

    private static var primaryBlue: Color {
        return Color(light: Color(hex: 0x3F51B5), dark: Color(hex: 0x5C6BC0))
    }

    private static var primaryDarkBlue: Color {
        return Color(light: Color(hex: 0x303F9F), dark: Color(hex: 0x3F51B5))
    }

    public static var accentYellow: Color {
        return Color(hex: 0xFFD600)
    }

    public static var highlightColor: Color {
        return Color(light: .primaryBlue, dark: .accentYellow)
    }

    public static var navigationBarColor: Color {
        return Color(light: .primaryBlue, dark: .backgroundGray)
    }

    public static var navigationBarTintColor: Color {
        return Color(light: .white, dark: .accentYellow)
    }

    public static var tabBarTintColor: Color {
        return Color(light: .blue, dark: .accentYellow)
    }

    public static var tableViewHeaderColor: Color {
        return Color(light: .primaryDarkBlue, dark: .primaryGray)
    }

    public static var segmentedControlSelectedColor: Color {
        return Color(light: .primaryBlue, dark: .white)
    }

    /*
    public static var yearSelectColor: Color {
        return Color(light: .white, dark: Color(uiColor: .systemGray5))
    }
    */

    private static var primaryGray: Color {
        return Color(.systemGray4)
    }

    private static var backgroundGray: Color {
        return Color(.systemGray6)
    }

    public static var systemBackground: Color {
        return Color(uiColor: UIColor.systemBackground)
    }
}

private extension Color {
    init(light: Color, dark: Color) {
        self = Color(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            alpha: alpha
        )
    }
}
