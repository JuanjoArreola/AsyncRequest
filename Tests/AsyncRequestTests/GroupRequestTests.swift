//
//  GroupRequestTests.swift
//  AsyncRequestTests
//
//  Created by Juan Jose Arreola on 18/11/17.
//

import XCTest
import AsyncRequest

class GroupRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuccessInit() {
        let expectation = self.expectation(description: "init")
        
        let group = RequestGroup {
        }.fail { errors in
            XCTFail()
        }.finished {
            expectation.fulfill()
        }
        group.add(request: Request<String>.completed(with: "Test", in: DispatchQueue.main))
        group.startObserving()
        
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testSuccess() {
        let expectation = self.expectation(description: "success")
        
        let group = RequestGroup()
        group.success {
            XCTAssertTrue(group.completed)
            XCTAssertTrue(group.successful ?? false)
        }.fail { errors in
            XCTFail()
        }.finished {
            expectation.fulfill()
        }
        group.add(request: Request<String>.completed(with: "Test", in: DispatchQueue.main))
        group.add(request: Request<String>.completed(with: "Test2", in: DispatchQueue.main))
        group.startObserving()
        
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testSucceeded() {
        let expectation = self.expectation(description: "succeeded")
        
        let group = RequestGroup()
        group.fail { _ in
            XCTFail()
        }
        group.add(request: Request<String>.completed(with: "Test", in: DispatchQueue.main))
        group.startObserving()
        
        DispatchQueue.main.async {
            group.success {
                XCTAssertTrue(group.completed)
            }.finished {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testFail() {
        let expectation = self.expectation(description: "fail")
        
        let group = RequestGroup()
        group.success {
            XCTFail()
        }.fail { errors in
            XCTAssertGreaterThan(errors.count, 0)
        }.finished {
            expectation.fulfill()
        }
        group.add(request: Request<String>.completed(with: "Test", in: DispatchQueue.main))
        group.add(request: Request<String>.completed(with: TestError.test, in: DispatchQueue.main))
        group.startObserving()
        
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testFailed() {
        let expectation = self.expectation(description: "fail")
        
        let group = RequestGroup()
        group.add(request: Request<String>.completed(with: TestError.test, in: DispatchQueue.main))
        group.startObserving()
        
        DispatchQueue.main.async {
            group.success {
                XCTFail()
            }.fail { errors in
                XCTAssertGreaterThan(errors.count, 0)
            }.finished {
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 4.0)
    }
    
    func testEveryError() {
        let expectation = self.expectation(description: "every error")
        let errorExpectation = self.expectation(description: "every error")
        var errorCount = 0 {
            didSet {
                if errorCount >= 2 {
                    errorExpectation.fulfill()
                }
            }
        }
        
        let group = RequestGroup()
        group.everyFail { _ in
            errorCount += 1
        }.finished {
            expectation.fulfill()
        }
        let first = Request<String>()
        let last = Request<String>()
        group.add(request: first)
        group.add(request: last)
        group.startObserving()
        
        first.complete(with: TestError.test)
        last.complete(with: TestError.test)
        
        wait(for: [expectation, errorExpectation], timeout: 4.0)
    }
    
}
