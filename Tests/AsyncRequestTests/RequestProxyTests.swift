//
//  RequestProxyTests.swift
//  AsyncRequest
//
//  Created by Juan Jose Arreola on 18/05/17.
//
//

import XCTest
import AsyncRequest

class RequestProxyTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCompleteSuccess() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompleteSuccess")
        
        let request = Request<String>()
        _ = request.proxy(completion: { getResult in
            do {
                let string = try getResult()
                XCTAssertEqual(string, "Test")
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        })
        
        request.complete(with: "Test")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccess() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccess")
        
        let request = Request<String>()
        _ = request.proxy(success: { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        })
        
        request.complete(with: "Test")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCompleteError() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompleteError")
        
        let request = Request<String>()
        _ = request.proxy(completion: { getResult in
            do {
                _ = try getResult()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        })
        
        request.complete(with: TestError.test)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccessAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccessAfterComplete")
        
        let request = Request<String>()
        request.complete(with: "Test")
        
        _ = request.proxy(success: { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccessAfterComplete")
        
        let request = Request<String>()
        request.complete(with: TestError.test)
        
        let proxy = request.proxy(success: { string in
            XCTFail()
        })
        proxy.fail { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCancelParent() {
        let expectation: XCTestExpectation = self.expectation(description: "testCancelParent")
        
        let request = Request<String>()
        request.cancel()
        
        let proxy = request.proxy(success: { string in
            XCTFail()
        })
        proxy.fail { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCancelProxy() {
        let errorExpectation: XCTestExpectation = self.expectation(description: "error")
        let expectation: XCTestExpectation = self.expectation(description: "success")
        
        let request = Request<String>(successHandler: { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        })
        
        let proxy = request.proxy(success: { string in
            XCTFail()
        })
        proxy.fail { _ in
            errorExpectation.fulfill()
        }
        proxy.cancel()
        
        request.complete(with: "Test")
        
        wait(for: [expectation, errorExpectation], timeout: 1.0)
    }
    
}
