import Foundation

class RetryService {

    private var retryTimer: Timer?
    private weak var retryRunLoop: RunLoop?

    public var isRetryRegistered: Bool {
        return retryTimer != nil
    }

    deinit {
        unregister()
    }

    private static func createTimer(_ retryable: Retryable) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: retryable.retryInterval, repeats: true, block: { (_) in
            retryable.retry()
        })
    }

    fileprivate func register(_ retryable: Retryable, initiallyRetry: Bool = true) {
        if retryTimer != nil {
            assertionFailure("Registering with retry service multiple times")
            return
        }

        retryTimer = RetryService.createTimer(retryable)
        retryRunLoop = RunLoop.current

        if initiallyRetry {
            retryTimer?.fire()
        }
    }

    fileprivate func unregister() {
        weak var retryTimer = self.retryTimer
        retryRunLoop?.perform {
            retryTimer?.invalidate()
        }
        self.retryTimer = nil
    }

}

protocol Retryable {
    var retryService: RetryService { get set }
    /// The number of seconds between retries
    var retryInterval: TimeInterval { get }

    func retry()
}

extension Retryable {

    func registerRetryable(initiallyRetry: Bool = false) {
        retryService.register(self, initiallyRetry: initiallyRetry)
    }

    func unregisterRetryable() {
        retryService.unregister()
    }

}
