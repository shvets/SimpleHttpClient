import XCTest

@testable import SimpleHttpClient

struct Author: Codable {
  let name: String
}

struct Book: Codable {
  let title: String
  let authorIdentifier: Identifier<Author>
}

class IdentifierTests: XCTestCase {
  let authorJson = """
                   {
                       "identifier": "A13424B6",
                       "name": "Robert C. Martin"
                   }
                   """.data(using: .utf8)!

  let bookJson = """
                 {
                     "identifier": "A161F15C",
                     "title": "Clean Code",
                     "authorIdentifier": "A13424B6"
                 }
                 """.data(using: .utf8)!

  func testIdentifierDecode() throws {
    let author = try JSONDecoder().decode(Identified<Author>.self, from: authorJson)

    XCTAssertEqual(author.identifier.value, "A13424B6")
    XCTAssertEqual(author.value.name, "Robert C. Martin")

    let book = try JSONDecoder().decode(Identified<Book>.self, from: bookJson)

    XCTAssertEqual(book.identifier.value, "A161F15C")
    XCTAssertEqual(book.value.title, "Clean Code")
    XCTAssertEqual(book.value.authorIdentifier.value, "A13424B6")
  }
}
