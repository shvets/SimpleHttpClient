import XCTest

@testable import SimpleHttpClient

final class StorageTests: XCTestCase {
  func testStorage() throws {
    struct Timeline: Codable, Equatable {
      let tweets: [String]
    }

    let path = URL(fileURLWithPath: NSTemporaryDirectory())
    let disk = DiskStorage(path: path)
    let storage = CodableStorage(storage: disk)

    let timeline = Timeline(tweets: ["Hello", "World", "!!!"])
    try storage.save(timeline, for: "timeline")
    let cached: Timeline = try storage.fetch(for: "timeline")

    XCTAssertEqual(cached, timeline)
  }
}
