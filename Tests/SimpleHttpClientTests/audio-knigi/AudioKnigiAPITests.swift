import XCTest
import Files

@testable import SimpleHttpClient

class AudioKnigiAPITests: XCTestCase {
  var subject = AudioKnigiAPI()

  func testGetAuthorsLetters() throws {
    let result = try subject.getAuthorsLetters()

    print(try result.prettify())
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }


  func testGetBestBooks() throws {
    let result = try subject.getBestBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

//  func testGetBestBooksByMonth() throws {
//    let exp = expectation(description: "Gets best books by month")
//
//    _ = subject.getBestBooks(period: "30").subscribe(onNext: { result in
//      //print(result as Any)
//
//      XCTAssert(result.count > 0)
//
//      exp.fulfill()
//    })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }
//
//  func testGetBestBooks() throws {
//    let exp = expectation(description: "Gets best books")
//
//    _ = subject.getBestBooks(period: "all").subscribe(onNext: { result in
//      //print(result as Any)
//
//      XCTAssert(result.count > 0)
//
//      exp.fulfill()
//    })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }

  func testGetAuthorBooks() throws {
    let result = try subject.getAuthors()

    if let id = result.items.first!["id"] {
      let books = try self.subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetPerformersBooks() throws {
    let result = try subject.getPerformers()

    if let id = result.items.first!["id"] {
      let books = try self.subject.getBooks(path: id)

      print(try books.prettify())

      XCTAssert(books.items.count > 0)
    }
  }

  func testGetAuthors() throws {
    let result = try subject.getAuthors()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetPerformers() throws {
    let result = try subject.getPerformers()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetAllGenres() throws {
    let result = try subject.getGenres(page: 1)

    print(try result.prettify())

    XCTAssert(result.items.count > 0)

    let result2 = try subject.getGenres(page: 2)

    print(try result2.prettify())

    XCTAssert(result2.items.count > 0)
  }

  func testGetGenre() throws {
    let genres = try subject.getGenres(page: 1)

    if let item = genres.items.first {
      if let id = item["id"] {
        let genre = try self.subject.getGenre(path: id)

        print(try genre.prettify())

        XCTAssert(genre.items.count > 0)
      }
    }
  }

  func testPagination() throws {
    let result1 = try subject.getNewBooks(page: 1)

    if let pagination1 = result1.pagination {
      XCTAssertEqual(pagination1.has_next, true)
      XCTAssertEqual(pagination1.has_previous, false)
      XCTAssertEqual(pagination1.page, 1)
    }

    let result2 = try subject.getNewBooks(page: 2)

    if let pagination2 = result2.pagination {
      XCTAssertEqual(pagination2.has_next, true)
      XCTAssertEqual(pagination2.has_previous, true)
      XCTAssertEqual(pagination2.page, 2)
    }
  }

  func testGetAudioTracks() throws {
    let path = "luchshee-yumoristicheskoe-fentezi-antologiya-chast-1"

    let result = try subject.getAudioTracks(path)
//      do {
//        print(try result.prettify())
//      }
//      catch {
//
//      }

    XCTAssertNotNil(result)
    XCTAssert(result.count > 0)
  }

//  func testSearch() throws {
//    let query = "пратчетт"
//
//    let exp = expectation(description: "Search")
//
//    _ = subject.search(query).subscribe(onNext: { result in
//      //print(result as Any)
//
//      XCTAssert(result.count > 0)
//
//      exp.fulfill()
//    })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }
//
//  func testGrouping() throws {
//    let data: Data? = try File(path: "authors.json").read()
//
//    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]
//
//    let classifier = NameClassifier()
//    let classified = try classifier.classify(items: items)
//
//    //print(classified)
//
//    XCTAssert(classified.count > 0)
//  }
//
//  func testGenerateAuthorsList() throws {
//    try generateAuthorsList("authors.json")
//  }
//
//  func testGeneratePerformersList() throws {
//    try generatePerformersList("performers.json")
//  }
//
//  func testGenerateAuthorsInGroupsList() throws {
//    let data: Data? = try File(path: "authors.json").read()
//
//    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]
//
//    let classifier = NameClassifier()
//    let classified = try classifier.classify2(items: items)
//
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    let data2 = try encoder.encode(classified)
//
//    //print(data2)
//
//    try FileSystem().createFile(at: "authors-in-groups.json", contents: data2)
//  }
//
//  func testGeneratePerformersInGroupsList() throws {
//    let data: Data? = try File(path: "performers.json").read()
//
//    let items: [NameClassifier.Item] = try data!.decoded() as [NameClassifier.Item]
//
//    let classifier = NameClassifier()
//    let classified = try classifier.classify2(items: items)
//
//    let encoder = JSONEncoder()
//    encoder.outputFormatting = .prettyPrinted
//    let data2 = try encoder.encode(classified)
//
//    //print(data2)
//
//    try FileSystem().createFile(at: "performers-in-groups.json", contents: data2)
//  }
//
//  private func generateAuthorsList(_ fileName: String) throws {
//    var list = [Any]()
//
//    let semaphore1 = DispatchSemaphore.init(value: 0)
//
//    _ = subject.getAuthors().subscribe(onNext: { result in
//      list += (result["items"] as! [Any])
//
//      let pagination = result["pagination"] as! [String: Any]
//
//      let semaphore2 = DispatchSemaphore.init(value: 0)
//
//      let pages = pagination["pages"] as! Int
//
//      for page in (2...pages) {
//        _ = self.subject.getAuthors(page: page).subscribe(onNext: { result in
//          list += (result["items"] as! [Any])
//
//          semaphore2.signal()
//        })
//
//        _ = semaphore2.wait(timeout: DispatchTime.distantFuture)
//      }
//
//      semaphore1.signal()
//    })
//
//    _ = semaphore1.wait(timeout: DispatchTime.distantFuture)
//
//    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }
//
//    try FileSystem().createFile(at: fileName, contents: try asPrettifiedData(filteredList))
//  }
//
//  private func generatePerformersList(_ fileName: String) throws {
//    var list = [Any]()
//
//    let semaphore1 = DispatchSemaphore.init(value: 0)
//
//    _ = subject.getPerformers().subscribe(onNext: { result in
//      list += (result["items"] as! [Any])
//
//      let pagination = result["pagination"] as! [String: Any]
//
//      let semaphore2 = DispatchSemaphore.init(value: 0)
//
//      let pages = pagination["pages"] as! Int
//
//      for page in (2...pages) {
//        _ = self.subject.getPerformers(page: page).subscribe(onNext: { result in
//          list += (result["items"] as! [Any])
//
//          semaphore2.signal()
//        })
//
//        _ = semaphore2.wait(timeout: DispatchTime.distantFuture)
//      }
//
//      semaphore1.signal()
//    })
//
//    _ = semaphore1.wait(timeout: DispatchTime.distantFuture)
//
//    let filteredList = list.map {["id": ($0 as! [String: String])["id"]!, "name": ($0 as! [String: String])["name"]!] }
//
//    try FileSystem().createFile(at: fileName, contents: try asPrettifiedData(filteredList))
//  }
//
//  var encoder: JSONEncoder = {
//    let encoder = JSONEncoder()
//
//    encoder.outputFormatting = .prettyPrinted
//
//    return encoder
//  }()
//
//  public func asPrettifiedData(_ value: Any) throws -> Data {
//    if let value = value as? [[String: String]] {
//      return try encoder.encode(value)
//    }
//    else if let value = value as? [String: String] {
//      return try encoder.encode(value)
//    }
//
//    return Data()
//  }
}
