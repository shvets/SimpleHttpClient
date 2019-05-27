import XCTest
import Files

@testable import SimpleHttpClient

class StringConfigFileTests: XCTestCase {
  let path = URL(fileURLWithPath: NSTemporaryDirectory())

  var subject: StringConfigFile = StringConfigFile("test.config")

  func testSave() throws {
    let exp = expectation(description: "Tests Save")

    //try File(path: subject.fileName).delete()

    let data = ["key1": "value1", "key2": "value2"]

    subject.items = data

    try subject.write().subscribe(onNext: { items in
      exp.fulfill()
      XCTAssertEqual(items.keys.count, 2)
    })

    waitForExpectations(timeout: 10)
  }

  func testLoad() throws {
    let exp = expectation(description: "Tests Load")

    let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

    try FileSystem().createFile(at: subject.fileName, contents: data!)

    try subject.read().subscribe(onNext: { items in
      exp.fulfill()
      XCTAssertEqual(items.keys.count, 2)
    })

    waitForExpectations(timeout: 10)
  }

}
