import Foundation
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct SearchContainerTests {

    /// A container whose search controller has gone through `setupSearchController()` inside a
    /// navigation controller and a window, which is what resets the field's appearance.
    ///
    /// The tab bar controller is load bearing. Without one the bar has room to place the search
    /// field inline, and UIKit swaps in its own SwiftUI-backed field that drops our colors.
    private final class Harness {
        let window: UIWindow
        let container: TeamsContainerViewController

        init(style: UIUserInterfaceStyle) {
            container = TeamsContainerViewController(dependencies: .mock())
            window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
            window.overrideUserInterfaceStyle = style
            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [
                UINavigationController(rootViewController: container)
            ]
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
            container.loadViewIfNeeded()
            window.layoutIfNeeded()
        }

        var searchTextField: UISearchTextField {
            container.searchController.searchBar.searchTextField
        }
    }

    private static func expectStyled(
        _ harness: Harness,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let searchTextField = harness.searchTextField
        let traits = searchTextField.traitCollection

        #expect(searchTextField.textColor == UIColor.white, sourceLocation: sourceLocation)
        #expect(searchTextField.tintColor == UIColor.white, sourceLocation: sourceLocation)
        #expect(
            searchTextField.leftView?.tintColor == UIColor.white,
            sourceLocation: sourceLocation
        )
        #expect(
            searchTextField.backgroundColor?.resolvedColor(with: traits)
                == UIColor.searchFieldBackgroundColor.resolvedColor(with: traits),
            sourceLocation: sourceLocation
        )
        let placeholderColor = searchTextField.attributedPlaceholder?.attribute(
            .foregroundColor,
            at: 0,
            effectiveRange: nil
        ) as? UIColor
        #expect(
            placeholderColor == UIColor.white.withAlphaComponent(0.7),
            sourceLocation: sourceLocation
        )
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func searchFieldKeepsItsStylingOnceTheNavigationItemAdoptsTheBar(style: UIUserInterfaceStyle) {
        Self.expectStyled(Harness(style: style))
    }

    @Test func searchFieldKeepsItsStylingAcrossAnAppearanceChange() {
        let harness = Harness(style: .light)
        harness.window.overrideUserInterfaceStyle = .dark
        harness.window.layoutIfNeeded()

        Self.expectStyled(harness)

        // The field carries the dynamic color itself, not a light-mode snapshot of it.
        let traits = harness.searchTextField.traitCollection
        #expect(traits.userInterfaceStyle == .dark)
        #expect(
            harness.searchTextField.backgroundColor?.resolvedColor(with: traits)
                == UIColor.systemGray5.resolvedColor(with: traits)
        )
    }

}
