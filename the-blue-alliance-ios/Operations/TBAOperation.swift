import Foundation

class TBAOperation: Operation {

    var completionError: Error?

    internal var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }

        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    internal var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }

        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    internal var _cancelled = false {
        willSet {
            willChangeValue(forKey: "isCancelled")
        }

        didSet {
            didChangeValue(forKey: "isCancelled")
        }
    }

    override var isExecuting: Bool {
        return _executing
    }

    override var isFinished: Bool {
        return _finished
    }

    override var isCancelled: Bool {
        return _cancelled
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isConcurrent: Bool {
        return true
    }

    override func start() {
        if _cancelled {
            finish()
            return
        }
        _executing = true

        execute()
    }

    override func cancel() {
        _cancelled = true

        super.cancel()
    }

    func execute() {
        assertionFailure("Implement execute in superclass")
    }

    internal func finish() {
        _executing = false
        _finished = true
    }

}
