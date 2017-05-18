import Foundation

private let syncQueue: DispatchQueue = DispatchQueue(label: "com.request.SyncQueue", attributes: .concurrent)

class RequestHandlers<T> {
    
    private var completionHandlers: [(_ getObject: () throws -> T) -> Void] = []
    
    private var successHandlers: [(T) -> Void] = []
    private var errorHandlers: [(Error) -> Void] = []
    private var finishHandlers: [() -> Void] = []
    
    private var proxies: [Request<T>] = []
    
    func add(successHandler: @escaping (T) -> Void) {
        successHandlers.append(successHandler)
    }
    
    func add(errorHandler: @escaping (Error) -> Void) {
        errorHandlers.append(errorHandler)
    }
    
    func add(finishHandler: @escaping () -> Void) {
        finishHandlers.append(finishHandler)
    }
    
    func add(completionHandler: @escaping (_ getResult: () throws -> T) -> Void) {
        completionHandlers.append(completionHandler)
    }
    
    func add(proxy: Request<T>) {
        proxies.append(proxy)
    }
    
    func complete(with object: T) {
        proxies.forEach({ $0.complete(with: object) })
        completionHandlers.forEach({ $0({ return object }) })
        successHandlers.forEach({ $0(object) })
        finishHandlers.forEach({ $0() })
        clear()
    }
    
    func complete(with error: Error) {
        proxies.forEach({ $0.complete(with: error) })
        completionHandlers.forEach({ $0({ throw error }) })
        errorHandlers.forEach({ $0(error) })
        finishHandlers.forEach({ $0() })
        clear()
    }
    
    func clear() {
        completionHandlers = []
        successHandlers = []
        errorHandlers = []
        finishHandlers = []
        proxies = []
    }
}
