import Foundation

protocol URLOpener {
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [String : Any], completionHandler completion: ((Bool) -> Swift.Void)?)
}
