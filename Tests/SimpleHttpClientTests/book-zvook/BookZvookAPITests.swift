import XCTest

@testable import SimpleHttpClient

class BookZvookAPITests: XCTestCase {
  var subject =  BookZvookAPI()

  func testGetPopularBooks() throws {
    let result = try subject.getPopularBooks()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetAuthorBooks() throws {
    let letters = try subject.getLetters()

    let id = letters[1]["id"]!

    let authors = try self.subject.getAuthorsByLetter(id)

    let result = try subject.getAuthorBooks(id, name: authors[0].name)

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetLetters() throws {
    let result = try subject.getLetters()

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetAuthorsByLetter() throws {
    let letters = try subject.getLetters()

    let id = letters[1]["id"]!

    let result = try self.subject.getAuthorsByLetter(id)

    print(try result.prettify())

    XCTAssert(result.count > 0)
  }

  func testGetGenres() throws {
    let result = try subject.getGenres()

    print(try result.prettify())
  }

  func testGetPlaylistUrls() throws {
    let url = "http://bookzvuk.ru/zhizn-i-neobyichaynyie-priklyucheniya-soldata-ivana-chonkina-1-litso-neprikosnovennoe-vladimir-voynovich-audiokniga-onlayn/"

    let result = try self.subject.getPlaylistUrls(url)

    print(try result.prettify())
  }

  func testGetAudioTracks() throws {
    let url = "http://bookzvuk.ru/zemlekopyi-terri-pratchett-audiokniga-onlayn/"
    let playlistUrls = try subject.getPlaylistUrls(url)

    //print(playlistUrls)

    let list = try subject.getAudioTracks(playlistUrls[0])

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetNewBooks() throws {
    let result = try subject.getNewBooks()

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testGetGenreBooks() throws {
    let genreUrl = "http://bookzvuk.ru/category/bestseller/"
    let path = String(genreUrl[BookZvookAPI.SiteUrl.index(genreUrl.startIndex, offsetBy: BookZvookAPI.SiteUrl.count)...])

    let result = try subject.getGenreBooks(path)

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }

  func testSearch() throws {
    let query = "пратчетт"

    let result = try subject.search(query, page: 2)

    print(try result.prettify())

    XCTAssert(result.items.count > 0)
  }
}
