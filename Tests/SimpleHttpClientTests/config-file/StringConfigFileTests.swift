import XCTest
import Files

@testable import SimpleHttpClient

class StringConfigFileTests: XCTestCase {
  var subject = StringConfigFile(Folder.current.path + "test.config")

  func testSave() throws {
    try File(path: subject.fileName).delete()

    let data = ["key1": "value1", "key2": "value2"]

    subject.items = data

    try subject.save()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

  func testLoad() throws {
    let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

    try FileSystem().createFile(at: subject.fileName, contents: data!)

    try subject.load()

    XCTAssertEqual(subject.items.keys.count, 2)
  }

}
