import Foundation

// If the model has a website, it's surfable on the world wide web
protocol Surfable {
    var website: String? { get set }
}

extension Surfable {

    var hasWebsite: Bool {
        if let website = website, !website.isEmpty {
            return true
        }
        return false
    }

}
