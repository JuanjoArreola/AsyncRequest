import XCTest
import AsyncRequest

class CompletionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCompletion() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompletion")
        
        let request = Request<String>(completionHandler: { (getResult) in
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
    
    func testCompletionError() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompletionError")
        
        let request = Request<String>(completionHandler: { (getResult) in
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
    
    func testCompletionAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testCompletionAfterComplete")
        
        let request = Request<String>()
        request.complete(with: "Test")
        
        request.add(completionHandler: { (getResult) in
            do {
                let string = try getResult()
                XCTAssertEqual(string, "Test")
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        })
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testErrorAfterComplete() {
        let expectation: XCTestExpectation = self.expectation(description: "testErrorAfterComplete")
        
        let request = Request<String>()
        request.complete(with: TestError.test)
        
        request.add(completionHandler: { (getResult) in
            do {
                _ = try getResult()
                XCTFail()
            } catch {
                expectation.fulfill()
            }
        })
        
        wait(for: [expectation], timeout: 1.0)
    }

}
