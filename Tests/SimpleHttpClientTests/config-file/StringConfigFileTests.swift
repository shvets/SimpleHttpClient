import XCTest
import Files

@testable import SimpleHttpClient

class StringConfigFileTests: XCTestCase {
  // Folder.current.path +
  var subject = StringConfigFile("test.config")

  func testSave() throws {
    //try File(path: subject.fileName).delete()

    let data = ["key1": "value1", "key2": "value2"]

    subject.items = data

    try subject.write()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

  func testLoad() throws {
    let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

    try FileSystem().createFile(at: subject.fileName, contents: data!)

    try subject.read()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

}
