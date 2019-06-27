import XCTest
import Files

@testable import SimpleHttpClient

class ConfigFileTests: XCTestCase {
  static let path = URL(fileURLWithPath: NSTemporaryDirectory())

  let subject: ConfigFile = ConfigFile<String>(path: path, fileName: "test.config")

  func testSave() throws {
    //try File(path: subject.fileName).delete()

    subject.items["key1"] = "value1"
    subject.items["key2"] = "value2"

    if let items = try subject.write() {
      print(try items.prettify())

      XCTAssertEqual(items.asDictionary().keys.count, 2)
    }
    else {
      XCTFail("Error: empty response")
    }
  }

  func testLoad() throws {
    let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

    try FileSystem().createFile(at: subject.name, contents: data!)

    if let items = try subject.read() {
      print(try items.prettify())

      XCTAssertEqual(items.asDictionary().keys.count, 2)
    }
    else {
      XCTFail("Error: empty response")
    }
  }
}
