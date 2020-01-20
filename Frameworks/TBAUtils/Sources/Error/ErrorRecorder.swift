import Foundation

public protocol ErrorRecorder {
    func recordError(_ error: Error)
}
