import XCTest
import Files

@testable import SimpleHttpClient

class ConfigFileTests: XCTestCase {
  let path = URL(fileURLWithPath: NSTemporaryDirectory())

  var subject: ConfigFile = ConfigFile<String>("test.config")

  func testSave() throws {
    let exp = expectation(description: "Tests Save")

    //try File(path: subject.fileName).delete()

    subject.items["key1"] = "value1"
    subject.items["key2"] = "value2"

    subject.write().subscribe(onNext: { items in
      exp.fulfill()
      XCTAssertEqual(items.asDictionary().keys.count, 2)
    })

    waitForExpectations(timeout: 10)
  }

  func testLoad() throws {
    let exp = expectation(description: "Tests Load")

    let data = "{\"key1\": \"value1\", \"key2\": \"value2\"}".data(using: .utf8)

    try FileSystem().createFile(at: subject.name, contents: data!)

    subject.read().subscribe(onNext: { items in
      exp.fulfill()

      XCTAssertEqual(items.asDictionary().keys.count, 2)
    }, onError: { (error) -> Void in
      exp.fulfill()
      print(error)
      XCTFail()
    })

    waitForExpectations(timeout: 10)
  }
}
