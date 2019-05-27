import XCTest

@testable import SimpleHttpClient

final class DiskStorageTests: XCTestCase {
  func testStorage() throws {
    let exp = expectation(description: "Tests Get API")

    struct Timeline: Codable, Equatable {
      let tweets: [String]
    }

    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let storage = DiskStorage(path: path)

    let timeline = Timeline(tweets: ["Hello", "World", "!!!"])

    storage.writeAsync(timeline, for: "timeline") { _ in
      storage.readAsync(Timeline.self, for: "timeline") { result in
        print(try? result.get())

        XCTAssertEqual(try? result.get(), timeline)

        exp.fulfill()
      }
    }

    waitForExpectations(timeout: 10)
  }
}
