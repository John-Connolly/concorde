import XCTest
@testable import concord

final class concordTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(concord().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
