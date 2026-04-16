import Foundation

enum TBAAPIError: Error {
    case notModified
    case unauthorized
    case notFound
    case unexpectedStatus(Int)
}
