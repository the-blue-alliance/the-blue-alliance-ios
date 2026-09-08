import UIKit

extension UIApplication: URLOpener {

    func open(_ url: URL) {
        Task { await open(url, options: [:]) }
    }

}
