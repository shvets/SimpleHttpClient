import XCTest

@testable import SimpleHttpClient

final class AnyEncoderDecoderTests: XCTestCase {
  struct User: Codable, Equatable {
    let firstName: String
    let lastName: String
  }

  func testEncoded() throws {
    let user = User(firstName: "Harry", lastName: "Potter")

    XCTAssertEqual(try user.encoded().count, 52)
  }

  func testPrettify() throws {
    let user = User(firstName: "Harry", lastName: "Potter")

    print(try user.prettify())

    let result = try user.prettify()

    XCTAssertTrue(result.contains("\"firstName\" : \"Harry\""))
  }
}
