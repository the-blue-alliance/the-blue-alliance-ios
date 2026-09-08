import Foundation
import UIKit

protocol URLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL)
}
