import XCTest

@testable import SimpleHttpClient

struct Author: Codable {
  let id: Identifier<String>
  let name: String
}

//extension Author: Equatable {
//  static func == (lhs: Author, rhs: Author) -> Bool {
//    return lhs.id == rhs.id
//  }
//}

struct Book: Codable {
  let title: String
  let authorId: Identifier<Author>
}

//extension Book: Equatable {
//  static func == (lhs: Book, rhs: Book) -> Bool {
//    return lhs.authorId == rhs.authorId
//  }
//}

class IdentifierTests: XCTestCase {
  let authorJson = """
                   {
                       "id": "A13424B6",
                       "name": "Robert C. Martin"
                   }
                   """.data(using: .utf8)!

  let bookJson = """
                 {
                     "id": "A161F15C",
                     "title": "Clean Code",
                     "authorId": "A13424B6"
                 }
                 """.data(using: .utf8)!

  func testIdentifierDecode() throws {
    let author = try JSONDecoder().decode(Identified<Author>.self, from: authorJson)

    XCTAssertEqual(author.id.value, "A13424B6")
    XCTAssertEqual(author.value.name, "Robert C. Martin")

    let book = try JSONDecoder().decode(Identified<Book>.self, from: bookJson)

    XCTAssertEqual(book.id.value, "A161F15C")
    XCTAssertEqual(book.value.title, "Clean Code")
    XCTAssertEqual(book.value.authorId.value, "A13424B6")
  }

  func testConstructor1() throws {
    let book = Book(title: "Some Title", authorId: Identifier(value: "A001"))

    print(book.authorId)
  }

  func testConstructor2() throws {
    let book = Book(title: "Some Title", authorId: "A001") // ExpressibleByStringLiteral

    print(book.authorId) // CustomStringConvertible

    //XCTAssertEqual(book.authorId, "A001")
  }

  func testWrongId() throws {
    let author = Author(id: "1", name: "Stephen King")
    //let book = Book(title: "Some Title", authorId: author.id) // fail
    let book = Book(title: "Some Title", authorId: Identifier(value: author.id.value)) // OK
    print(book)
  }
}
