import Foundation

// If the model has a website, it's surfable on the world wide web
public protocol Surfable {
    var website: String? { get }
}

extension Surfable {

    public var hasWebsite: Bool {
        if let website = website, !website.isEmpty {
            return true
        }
        return false
    }

}
