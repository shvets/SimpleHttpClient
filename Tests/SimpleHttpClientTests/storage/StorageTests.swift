import XCTest

@testable import SimpleHttpClient

final class StorageTests: XCTestCase {
  func testStorage() throws {
    struct Timeline: Codable, Equatable {
      let tweets: [String]
    }

    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let storage = CodableStorage(path: path)

    let timeline = Timeline(tweets: ["Hello", "World", "!!!"])
    try storage.write(timeline, for: "timeline")
    let cached: Timeline = try storage.read(for: "timeline")

    // print(cached)

    XCTAssertEqual(cached, timeline)
  }
}
