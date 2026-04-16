import Foundation

public protocol ErrorRecorder {
    func record(_ error: Error)
}
