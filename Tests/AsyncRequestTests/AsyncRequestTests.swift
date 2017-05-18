import XCTest
import AsyncRequest

class AsyncRequestTests: XCTestCase {
    
    func testSuccess() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccess")
        
        let request = Request<String>(successHandler: { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        })
        request.complete(with: "Test")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccessHandler() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccessHandler")
        
        let request = Request<String>()
        request.success { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        }
        
        request.complete(with: "Test")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSuccessAfterFinish() {
        let expectation: XCTestExpectation = self.expectation(description: "testSuccessHandler")
        
        let request = Request<String>()
        request.complete(with: "Test")
        
        request.success { string in
            XCTAssertEqual(string, "Test")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailure() {
        let expectation: XCTestExpectation = self.expectation(description: "testFailure")
        
        let request = Request<String>()
        request.fail { error in
            XCTAssertTrue(error is TestError)
            expectation.fulfill()
        }
        request.complete(with: TestError.test)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFinished() {
        let expectation: XCTestExpectation = self.expectation(description: "testFinished")
        
        let request = Request<String>()
        request.finished {
            expectation.fulfill()
        }
        request.complete(with: "Test")
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFinishedError() {
        let expectation: XCTestExpectation = self.expectation(description: "testFinished")
        
        let request = Request<String>()
        request.finished {
            expectation.fulfill()
        }
        request.complete(with: TestError.test)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCancel() {
        let expectation: XCTestExpectation = self.expectation(description: "testCancel")
        
        let request = Request<String>()
        request.add { getResult in
            do {
                _ = try getResult()
                XCTFail()
            } catch RequestError.canceled {
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        request.cancel()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSubrequest() {
        let expectation: XCTestExpectation = self.expectation(description: "testCancel")
        
        let subrequest = Request<String>()
        let request = Request<String>(subrequest: subrequest)
        subrequest.fail { error in
            expectation.fulfill()
        }
        request.cancel()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSubrequestAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testCancel")
        
        let request = Request<String>()
        request.cancel()
        
        let subrequest = Request<String>()
        request.subrequest = subrequest
        subrequest.fail { error in
            expectation.fulfill()
        }
        
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailureAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testFailureAfterComplete")
        
        let request = Request<String>()
        request.complete(with: TestError.test)
        
        request.fail { error in
            XCTAssertTrue(error is TestError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFinishedAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testFinished")
        
        let request = Request<String>()
        request.complete(with: TestError.test)
        
        request.finished {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }


    static var allTests = [
        ("testSuccess", testSuccess),
    ]
}

enum TestError: Error {
    case test
}
