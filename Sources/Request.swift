import Foundation

public enum RequestError: Error {
    case canceled
}

public protocol Cancellable {
    func cancel()
}

open class Request<T>: Cancellable {
    
    private var handlers: RequestHandlers<T>? = RequestHandlers<T>()
    
    private var object: T?
    private var error: Error?
    
    open var subrequest: Cancellable? {
        didSet {
            if let _ = error {
                subrequest?.cancel()
            }
        }
    }
    
    open var completed: Bool {
        return object != nil || error != nil
    }
    
    public init() {}
    
    public init(successHandler: @escaping (T) -> Void) {
        handlers?.add(successHandler: successHandler)
    }
    
    public init(completionHandler: @escaping (_ getObject: () throws -> T) -> Void) {
        handlers?.add(completionHandler: completionHandler)
    }
    
    public convenience init(subrequest: Cancellable) {
        self.init()
        self.subrequest = subrequest
    }
    
    /// Cancels the request and subrequest and call the handlers, subsequent calls are ignored
    open func cancel() {
        subrequest?.cancel()
        complete(with: RequestError.canceled)
    }
    
    open func complete(with object: T) {
        if !completed {
            self.object = object
            handlers?.complete(with: object)
            handlers = nil
        }
    }
    
    open func complete(with error: Error) {
        if !completed {
            self.error = error
            handlers?.complete(with: error)
            handlers = nil
        }
    }
    
    @discardableResult
    public func success(handler: @escaping (T) -> Void) -> Self {
        if let object = object {
            handler(object)
        } else {
            handlers?.add(successHandler: handler)
        }
        return self
    }
    
    @discardableResult
    public func fail(handler: @escaping (Error) -> Void) -> Self {
        if let error = error {
            handler(error)
        } else {
            handlers?.add(errorHandler: handler)
        }
        return self
    }
    
    @discardableResult
    public func finished(handler: @escaping () -> Void) -> Self {
        if completed {
            handler()
        } else {
            handlers?.add(finishHandler: handler)
        }
        return self
    }
    
    public func add(completionHandler completion: @escaping (_ getObject: () throws -> T) -> Void) {
        if let object = object {
            completion({ return object })
        } else if let error = error {
            completion({ throw error })
        } else {
            handlers?.add(completionHandler: completion)
        }
    }
    
    // MARK: - Proxy
    
    public func proxy(completion: @escaping (_ getObject: () throws -> T) -> Void) -> Request<T> {
        return setup(proxy: Request<T>(completionHandler: completion))
    }
    
    public func proxy(success: @escaping (T) -> Void) -> Request<T> {
        return setup(proxy: Request<T>(successHandler: success))
    }
    
    @inline(__always)
    private func setup(proxy: Request<T>) -> Request<T> {
        if let object = object {
            proxy.complete(with: object)
        } else if let error = error {
            proxy.complete(with: error)
        } else {
            handlers?.add(proxy: proxy)
        }
        return proxy
    }
}
