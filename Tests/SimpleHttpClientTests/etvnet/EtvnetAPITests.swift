import XCTest

@testable import SimpleHttpClient

class EtvnetAPITests: XCTestCase {
  static let path = URL(fileURLWithPath: NSTemporaryDirectory())

  static var configFile = ConfigFile<String>(path: path, fileName: "etvnet.config")

  var subject = EtvnetAPI(configFile: configFile)

  override func setUp() {
    super.setUp()
    do {
      try subject.authorize {
        do {
          if let result = try self.subject.apiClient.authorization() {
            print("Register activation code on web site \(self.subject.apiClient.authClient.getActivationUrl()): \(result.userCode)")

            if let response = self.subject.apiClient.createToken(userCode: result.userCode, deviceCode: result.deviceCode) {
              XCTAssertNotNil(response.accessToken)
              XCTAssertNotNil(response.refreshToken)

              print("Result: \(result)")
            }
          }
        } catch {
          XCTFail("Error: \(error)")
        }
      }
    } catch {
      XCTFail("Error: \(error)")
    }
  }

  func testGetChannels() throws {
    let channels = try subject.getChannels()

    print(try channels.prettify())

    XCTAssertNotNil(channels)
    XCTAssert(channels.count > 0)
  }

  func testGetArchive() throws {
    if let result = try subject.getArchive(channelId: 3) {
      print(try result.prettify())

      XCTAssertNotNil(result)
      XCTAssert(result.media.count > 0)
      XCTAssert(result.pagination.count > 0)
    }
    else {
      XCTFail()
    }
  }

  func testGetGenre() throws {
    if let result = try subject.getArchive(genre: 1) {
      print(try result.prettify())

      XCTAssertNotNil(result)
      XCTAssert(result.media.count > 0)
      XCTAssert(result.pagination.count > 0)
    }
    else {
      XCTFail()
    }
  }

  func testGetNewArrivals() throws {
    let data = try subject.getNewArrivals()!

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

//  func testGetBlockbusters() throws {
//    let exp = expectation(description: "Gets blockbusters")
//
//    _ = subject.getBlockbusters().subscribe(
//      onNext: { result in
//        print(result as Any)
//
//        XCTAssertNotNil(result)
//        XCTAssert(result!.media.count > 0)
//        XCTAssert(result!.pagination.count > 0)
//
//        exp.fulfill()
//      },
//      onError: { error in
//        print("Received error:", error)
//      })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }
//
//  func testGetCoolMovies() throws {
//    let exp = expectation(description: "Gets cool movies")
//
//    _ = subject.getCoolMovies(perPage: 15, page: 4).subscribe(
//      onNext: { result in
//        print(result as Any)
//
//        XCTAssertNotNil(result)
//        XCTAssert(result!.media.count > 0)
//        XCTAssert(result!.pagination.count > 0)
//
//        exp.fulfill()
//      },
//      onError: { error in
//        print("Received error:", error)
//      })
//
//    waitForExpectations(timeout: 10, handler: nil)
//  }

  func testGetGenres() throws {
    let list = try subject.getGenres()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testSearch() throws {
    let query = "news"
    let data = try subject.search(query)!

    print(try data.prettify())

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

  func testPagination() throws {
    let query = "news"

    let result1 = try subject.search(query, perPage: 20, page: 1)!
    let pagination1 = result1.pagination

    XCTAssertEqual(pagination1.hasNext, true)
    XCTAssertEqual(pagination1.hasPrevious, false)
    XCTAssertEqual(pagination1.page, 1)

    let result2 = try subject.search(query, perPage: 20, page: 2)!
    let pagination2 = result2.pagination

    XCTAssertEqual(pagination2.hasNext, true)
    XCTAssertEqual(pagination2.hasPrevious, true)
    XCTAssertEqual(pagination2.page, 2)
  }

  func testGetUrl() throws {
    let id = 760894 // 329678
    let  bitrate = "1200"
    let format = "mp4"

    let urlData = try subject.getUrl(id, format: format, mediaProtocol: "hls", bitrate: bitrate)

    print(try urlData.prettify())

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetLiveChannelUrl() throws {
    let id = 423
    let  bitrate = "800"
    let format = "mp4"

    let urlData = try subject.getLiveChannelUrl(id, format: format, bitrate: bitrate)

    print(try urlData.prettify())

    //    #print("Play list:\n" + self.service.get_play_list(url_data["url"]))
  }

  func testGetMediaObjects() throws {
    if let result = try subject.getArchive(channelId: 3) {
      var mediaObject: EtvnetAPI.Media? = nil

      for item in result.media {
        let type = item.mediaType

        if type == .mediaObject {
          mediaObject = item
          break
        }
      }

      if let mediaObject = mediaObject {
        print(try mediaObject.prettify())
      }
    }
    else {
      XCTFail()
    }
  }

  func testGetContainer() throws {
    if let result = try subject.getArchive(channelId: 5) {
      var container: EtvnetAPI.Media? = nil

      for item in result.media {
        let type = item.mediaType

        if type == .container {
          container = item
          break
        }
      }

      print(try container!.prettify())
    }
    else {
      XCTFail()
    }
  }

  func testGetAllBookmarks() throws {
    let data = try subject.getBookmarks()!

    print(try data.prettify())

    XCTAssertNotNil(data)
    XCTAssert(data.bookmarks.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

//  func testGetFolders() throws {
//    let result = subject.getFolders()
//
//    //print(result as Any)
//
//    XCTAssertEqual(result["status_code"], 200)
////        XCTAssert(result["data"].count > 0)
//  }

  func testGetBookmark() throws {
    let bookmarks = try subject.getBookmarks()!.bookmarks

    let bookmarkDetails = try subject.getBookmark(id: bookmarks[0].id)

    print(try bookmarkDetails.prettify())

    XCTAssertNotNil(bookmarkDetails)
  }

  func testAddBookmark() throws {
    let id = 760894

    let _ = try subject.addBookmark(id: id)

    //XCTAssertTrue(result)
  }

  func testRemoveBookmark() throws {
    let id = 760894

    let _ = try subject.removeBookmark(id: id)

    //XCTAssertTrue(result)
  }

  func testGetTopicItems() throws {
    for topic in EtvnetAPI.Topics {
      let data = try subject.getTopicItems(topic)!

      print(try data.prettify())

      XCTAssertNotNil(data)
      XCTAssert(data.media.count > 0)
      XCTAssert(data.pagination.count > 0)
    }
  }

  func testGetVideoResolution() {
    //    puts subject.bfuncrate_to_resolution(1500)
  }

  func testGetAllLiveChannels() throws {
    let list = try subject.getLiveChannels()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLiveChannelsByCategory() throws {
    let list = try subject.getLiveChannelsByCategory(category: 7)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetLiveFavoriteChannels() throws {
    let list = try subject.getLiveChannels(favoriteOnly: true)

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testAddFavoriteChannel() throws {
    let id = 46

    let result = try subject.addFavoriteChannel(id: id)

    print(result)
  }

  func testRemoveFavoriteChannel() throws {
    let id = 46

    let result = try subject.removeFavoriteChannel(id: id)

    print(result)
  }

  func testGetLiveSchedule() throws {
    let result = try subject.getLiveSchedule(liveChannelId: "59")

    //print(String(decoding: list, as: UTF8.self))

    print(result as Any)

    //XCTAssertNotNil(list)
//    XCTAssert(list.count > 0)
  }

  func testGetLiveCategories() throws {
    let list = try subject.getLiveCategories()

    print(try list.prettify())

    XCTAssertNotNil(list)
    XCTAssert(list.count > 0)
  }

  func testGetHistory() throws {
    let data = try subject.getHistory()!

    print(try data.prettify())

    XCTAssertNotNil(data)
    XCTAssert(data.media.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

  func testGetChildren() throws {
    let data = try subject.getChildren(488406)!

    print(try data.prettify())

    XCTAssertNotNil(data)
    XCTAssert(data.children.count > 0)
    XCTAssert(data.pagination.count > 0)
  }

}
