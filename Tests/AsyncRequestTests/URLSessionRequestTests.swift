//
//  URLSessionRequestTests.swift
//  AsyncRequest
//
//  Created by Juan Jose Arreola on 18/05/17.
//
//

import XCTest
import AsyncRequest

class URLSessionRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCancel() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompletion")
        
        let request = URLSessionRequest<String>()
        request.fail { error in
            XCTAssertEqual(request.dataTask?.state, URLSessionTask.State.canceling)
            expectation.fulfill()
        }
        let url = URL(string: "https://placeholdit.imgix.net/~text?txtsize=33&txt=AR&w=400&h=200&bg=0000ff")!
        request.dataTask = self.request(url: url, completion: { _ in })
        
        request.cancel()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func request(url: URL, completion: @escaping ((data: Data?, response: URLResponse?, error: Error?)) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }

}
