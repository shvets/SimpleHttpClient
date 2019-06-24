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
      storage.read(Timeline.self, for: "timeline") { result in
        do {
          print(try result.get())

          XCTAssertEqual(try result.get(), timeline)

          exp.fulfill()
        }
        catch {
          XCTFail()
        }
      }
    }

    waitForExpectations(timeout: 10)
  }
}
