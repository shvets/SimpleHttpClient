import XCTest

@testable import SimpleHttpClient

final class SimpleHttpClientTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SimpleHttpClient().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
