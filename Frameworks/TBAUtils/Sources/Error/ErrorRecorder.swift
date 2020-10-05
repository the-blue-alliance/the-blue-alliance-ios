import Foundation

public protocol ErrorRecorder {
    func log(_ format: String, _ args: [CVarArg])
    func record(_ error: Error)
}
