//
//  Color+TBA.swift
//  TBA
//
//  Created by Zachary Orr on 8/15/24.
//

import SwiftUI

public extension ShapeStyle where Self == Color {
    static var primaryBlue: Color {
        Color(light: Color(hex: 0x3F51B5), dark: Color(hex: 0x5C6BC0))
    }

    static var primaryDarkBlue: Color {
        Color(light: Color(hex: 0x303F9F), dark: Color(hex: 0x3F51B5))
    }

    static var accessoryColor: Color {
        Color(light: primaryBlue, dark: primaryDarkBlue)
    }

    static var accentColor: Color {
        Color(light: .primaryBlue, dark: .accentYellow)
    }

    static var accentYellow: Color {
        Color(hex: 0xFFD600)
    }

    static var highlightColor: Color {
        Color(light: .primaryBlue, dark: .accentYellow)
    }

    static var navigationBarColor: Color {
        Color(light: .primaryBlue, dark: .backgroundGray)
    }

    static var navigationBarTintColor: Color {
        Color(light: .white, dark: .accentYellow)
    }

    static var tabBarTintColor: Color {
        Color(light: .blue, dark: .accentYellow)
    }

    static var tableViewHeaderColor: Color {
        Color(light: .primaryDarkBlue, dark: .primaryGray)
    }

    static var segmentedControlSelectedColor: Color {
        Color(light: .primaryBlue, dark: .white)
    }

    /*
     public static var yearSelectColor: Color {
         return Color(light: .white, dark: Color(uiColor: .systemGray5))
     }
     */

    private static var primaryGray: Color {
        Color(.systemGray4)
    }

    private static var backgroundGray: Color {
        Color(.systemGray6)
    }

    static var systemBackground: Color {
        Color(uiColor: UIColor.systemBackground)
    }
}

private extension Color {
    init(light: Color, dark: Color) {
        self = Color(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                UIColor(dark)
            default:
                UIColor(light)
            }
        })
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha,
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            alpha: alpha,
        )
    }
}
