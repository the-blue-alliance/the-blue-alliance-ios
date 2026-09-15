import UIKit

extension UIButton {

    /// A capsule that opens a menu. Solid rather than glass so it reads the same whether the
    /// bar is over blue or over scrolled content.
    static func menuPill(menu: UIMenu? = nil) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        // White on the blue in light so it stands off the bar; the segment pill's gray in dark.
        configuration.baseBackgroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.systemGray2 : UIColor.white
        }
        configuration.baseForegroundColor = UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.white : UIColor.primaryBlue
        }
        configuration.image = UIImage(systemName: "chevron.down")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 5
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            textStyle: .body,
            scale: .small
        )
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 14,
            bottom: 8,
            trailing: 11
        )
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer {
            var attributes = $0
            attributes.font = UIFontMetrics(forTextStyle: .body).scaledFont(
                for: UIFont.systemFont(ofSize: 17, weight: .semibold)
            )
            return attributes
        }
        let button = UIButton(configuration: configuration)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
        // Otherwise it dims to gray while a sheet is presented over the screen.
        button.tintAdjustmentMode = .normal
        return button
    }

}
