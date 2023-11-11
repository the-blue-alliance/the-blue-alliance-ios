import Foundation

open class TBAOperation: Operation {

    public var completionError: Error?

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

    override open var isExecuting: Bool {
        return _executing
    }

    override open var isFinished: Bool {
        return _finished
    }

    override open var isCancelled: Bool {
        return _cancelled
    }

    override open var isAsynchronous: Bool {
        return true
    }

    override open var isConcurrent: Bool {
        return true
    }

    override open func start() {
        if _cancelled {
            finish()
            return
        }
        _executing = true

        execute()
    }

    override open func cancel() {
        _cancelled = true

        super.cancel()
    }

    open func execute() {
        assertionFailure("Implement execute in superclass")
    }

    open func finish() {
        _executing = false
        _finished = true
    }

}
