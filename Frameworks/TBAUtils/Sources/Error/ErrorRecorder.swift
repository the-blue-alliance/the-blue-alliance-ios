import Foundation

public protocol ErrorRecorder {
    func log(_ log: String, _ args: [CVarArg])
    func recordError(_ error: Error)
}
