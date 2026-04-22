import Foundation

public protocol Reporter {
    func record(_ error: Error)
    func log(_ message: String)
}
