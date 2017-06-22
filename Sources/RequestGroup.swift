import Foundation

class RequestGroup: Cancellable {
    
    var completed = false
    private var observing = false
    private var requests: [Cancellable] = []
    private var requestCount = 0
    
    private let finishHandler: () -> Void
    private let errorHandler: ((Error) -> Void)?
    
    init(finished: @escaping () -> Void, errorHandler: ((Error) -> Void)?) {
        self.finishHandler = finished
        self.errorHandler = errorHandler
    }
    
    func add<T>(request: Request<T>) {
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
    
    func startObserving() {
        observing = true
        update()
    }
    
    func cancel() {
        requests.forEach({ $0.cancel() })
    }
    
    private func update() {
        if !observing || requestCount > 0 { return }
        completed = true
        finishHandler()
        requests = []
    }
}
