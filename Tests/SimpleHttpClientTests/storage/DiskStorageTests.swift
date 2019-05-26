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

    storage.write(timeline, for: "timeline") { _ in
      storage.read(for: "timeline", type: Timeline.self) { result in
        print(try? result.get())

        XCTAssertEqual(try? result.get(), timeline)

        exp.fulfill()
      }
    }

    waitForExpectations(timeout: 10, handler: nil)
  }
}
