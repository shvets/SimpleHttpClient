import XCTest

@testable import SimpleHttpClient

class KinoKongAPITests: XCTestCase {
  var subject = KinoKongAPI()

  func testGetAvailable() throws {
    let result = try subject.available()

    XCTAssertEqual(result, true)
  }

  func testGetAllMovies() throws {
    let list = try subject.getAllMovies()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.items.count > 0)
  }

  func testGetNewMovies() throws {
    let list = try subject.getNewMovies()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.items.count > 0)
  }

  func testGetAllSeries() throws {
    let list = try subject.getAllSeries()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.items.count > 0)
  }

  func testGetGroupedGenres() throws {
    let list = try subject.getGroupedGenres()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetUrls() throws {
    let path = "34978-drakonchiki-2019.html"

    let list = try subject.getUrls(path)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSeriePlaylistUrl() throws {
    let path = "/25213-rodoslovnaya-03-06-2016.html"

    let url = try subject.getSeriePlaylistUrl(path)

    print(url)

    XCTAssertNotNil(url)
  }

  func _testGetMetadata() throws {
    let path = "26545-lovushka-dlya-privideniya-2015-smotret-online.html"

    let urls = try subject.getUrls(path)

    print(urls)

    let list = subject.getMetadata(urls[0])

    print(list)

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "красный"

    let list = try subject.search(query)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.items.count > 0)
  }

  func testPaginationInAllMovies() throws {
    let result1 = try subject.getAllMovies(page: 1)

    let pagination1 = result1.pagination

    print(try pagination1.prettify())

    XCTAssertTrue(pagination1!.has_next)
    XCTAssertFalse(pagination1!.has_previous)
    XCTAssertEqual(pagination1!.page, 1)

    let result2 = try subject.getAllMovies(page: 2)

    let pagination2 = result2.pagination

    print(try pagination2.prettify())

    XCTAssertTrue(pagination2!.has_next)
    XCTAssertTrue(pagination2!.has_previous)
    XCTAssertEqual(pagination2!.page, 2)
  }

  func testPaginationInMoviesByRating() throws {
    let result1 = try subject.getMoviesByRating(page: 1)

    let pagination1 = result1.pagination

    print(try pagination1.prettify())

    XCTAssertTrue(pagination1!.has_next)
    XCTAssertFalse(pagination1!.has_previous)
    XCTAssertEqual(pagination1!.page, 1)
  }

  func testGetMultipleSeasons() throws {
    let path = "22926-gomorra-1-4-sezon-2019.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    print(playlistUrl)

    let list = try subject.getSeasons(playlistUrl, path: path)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSingleSeason() throws {
    let path = "31759-orvill-06-10-2017.html"

    let playlistUrl = try subject.getSeriePlaylistUrl(path)

    print(playlistUrl)

    let list = try subject.getSeasons(playlistUrl, path: path)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetMoviesByRating() throws {
    let list = try subject.getMoviesByRating()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.items.count > 0)
  }

  func testGetTags() throws {
    let list = try subject.getTags()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetSoundtracks() throws {
    let path = "15479-smotret-dedpul-2016-smotet-online.html"

    let playlistUrl = try subject.getSoundtrackPlaylistUrl(path)

    print(playlistUrl)

    let list = try subject.getSoundtracks(playlistUrl)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }
}
