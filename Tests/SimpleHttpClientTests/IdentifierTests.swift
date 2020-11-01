import XCTest

@testable import Identity

struct Author: Identifiable, Codable {
  let id: ID
  let name: String
}

extension Author: Equatable {
  static func == (lhs: Author, rhs: Author) -> Bool {
    lhs.id == rhs.id
  }
}

struct Book: Identifiable, Codable {
  let id: ID
  let title: String
  let authorId: Identifier<Author>
}

extension Book: Equatable {
  static func == (lhs: Book, rhs: Book) -> Bool {
    lhs.authorId == rhs.authorId
  }
}

final class IdentifierTests: XCTestCase {
  let authorJson = """
                   {
                       "id": "A13424B6",
                       "name": "Robert C. Martin"
                   }
                   """.data(using: .utf8)!

  let bookJson = """
                 {
                     "id": "B161F15C",
                     "title": "Clean Code",
                     "authorId": "A13424B6"
                 }
                 """.data(using: .utf8)!

  func testIdentifierDecode() throws {
    let author = try JSONDecoder().decode(Author.self, from: authorJson)

    XCTAssertEqual(author.id.rawValue, "A13424B6")
    XCTAssertEqual(author.name, "Robert C. Martin")

    let book = try JSONDecoder().decode(Book.self, from: bookJson)

    XCTAssertEqual(book.id.rawValue, "B161F15C")
    XCTAssertEqual(book.title, "Clean Code")
    XCTAssertEqual(book.authorId.rawValue, "A13424B6")
  }

  func testConstructor1() throws {
    let book = Book(id: "B1111111", title: "Some Title", authorId: Identifier(rawValue: "A001"))

    print(book.authorId)
  }

  func testConstructor2() throws {
    let book = Book(id: "B1111111", title: "Some Title", authorId: "A001") // ExpressibleByStringLiteral

    print(book.authorId) // CustomStringConvertible

    XCTAssertEqual(book.authorId, "A001")
  }

  func testWrongId() throws {
    //let author = Author(id: "1", name: "Stephen King")
//    let book1 = Book(id: author.id, title: "Some Title", authorId: "A001") // fail
    let book = Book(id: "B1111111", title: "Some Title",  authorId: "A001") // OK

    print(book)
  }

  func testStringBasedIdentifier() {
    struct Model: Identifiable {
      let id: ID
    }

    let model = Model(id: "Hello, world!")
    XCTAssertEqual(model.id, "Hello, world!")
  }

  func testIntBasedIdentifier() {
    struct Model: Identifiable {
      typealias RawIdentifier = Int
      let id: ID
    }

    let model = Model(id: 7)
    XCTAssertEqual(model.id, 7)
  }

  func testCodableIdentifier() throws {
    struct Model: Identifiable, Codable {
      typealias RawIdentifier = UUID
      let id: ID
    }

    let model = Model(id: Identifier(rawValue: UUID()))
    let data = try JSONEncoder().encode(model)
    let decoded = try JSONDecoder().decode(Model.self, from: data)
    XCTAssertEqual(model.id, decoded.id)
  }

  func testIdentifierEncodedAsSingleValue() throws {
    struct Model: Identifiable, Codable {
      let id: ID
    }

    let model = Model(id: "I'm an ID")
    let data = try JSONEncoder().encode(model)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    XCTAssertEqual(json?["id"] as? String, "I'm an ID")
  }
}
