import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(SimpleHttpClientTests.allTests),
    ]
}
#endif
