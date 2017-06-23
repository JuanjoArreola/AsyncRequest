import Foundation

public class RequestGroup: Cancellable {
    
    public var completed = false
    private var observing = false
    private var requests: [Cancellable] = []
    private var requestCount = 0
    
    private let finishHandler: () -> Void
    private let errorHandler: ((Error) -> Void)?
    
    public init(finished: @escaping () -> Void, errorHandler: ((Error) -> Void)?) {
        self.finishHandler = finished
        self.errorHandler = errorHandler
    }
    
    public func add<T>(request: Request<T>) {
        if observing { return }
        requests.append(request)
        request.finished {
            self.requestCount -= 1
            self.update()
        }
        if let handler = errorHandler {
            request.fail(handler: handler)
        }
        requestCount += 1
    }
    
    public func startObserving() {
        observing = true
        update()
    }
    
    public func cancel() {
        requests.forEach({ $0.cancel() })
    }
    
    private func update() {
        if !observing || requestCount > 0 { return }
        completed = true
        finishHandler()
        requests = []
    }
}
