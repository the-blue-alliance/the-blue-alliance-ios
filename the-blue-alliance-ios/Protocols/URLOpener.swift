import Foundation
import UIKit

public protocol URLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?)
}
