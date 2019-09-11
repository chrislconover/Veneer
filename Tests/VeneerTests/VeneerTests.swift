import XCTest
@testable import Veneer

final class VeneerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Veneer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
