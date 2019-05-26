import XCTest

@testable import SimpleHttpClient

final class AnyEncoderDecoderTests: XCTestCase {
  struct User: Codable, Equatable {
    let firstName: String
    let lastName: String
  }

  func testEncoder() throws {
    let user = User(firstName: "Harry", lastName: "Potter")

    print(try user.prettify())

    XCTAssertEqual(try user.encoded().count, 52)
  }

  func testDecoder() throws {
    let user = User(firstName: "Harry", lastName: "Potter")
    let data = try user.encoded()

    let result = try data.decoded() as User

    print(try data.decoded() as User)

    XCTAssertEqual(result, user)
  }
}
