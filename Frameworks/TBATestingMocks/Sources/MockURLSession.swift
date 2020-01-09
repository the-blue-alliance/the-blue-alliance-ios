import XCTest

public class MockURLSession: URLSession {
    
    public var resumeExpectation: XCTestExpectation?
    public var cancelExpectation: XCTestExpectation?

    var tasksToVend: [MockURLSessionDataTask] = []

    public override init() {
        // Pass
    }

    override public func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return createTask(with: request)
    }
    
    override public func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return createTask(with: request, completionHandler: completionHandler)
    }
    
    func createTask(with request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> ())? = nil) -> URLSessionDataTask {
        let task = dequeueTaskToVend()
        task.completionHandler = completionHandler
        task.resumeExpectation = resumeExpectation
        task.cancelExpectation = cancelExpectation
        task.testRequest = request
        
        return task
    }
    
    func clearTasksToVend() {
        tasksToVend.removeAll()
    }
    
    func enqueueTaskToVend(task: MockURLSessionDataTask) {
        tasksToVend.append(task)
    }
    
    func dequeueTaskToVend() -> MockURLSessionDataTask {
        if let task = tasksToVend.first {
            return task
        }
        return MockURLSessionDataTask()
    }
    
}
