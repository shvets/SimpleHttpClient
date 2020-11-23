import XCTest

import Foundation
import Await

@testable import SimpleHttpClient

struct Post: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}

class ApiClientTests: XCTestCase {
  static let url = URL(string: "https://jsonplaceholder.typicode.com")

  var subject = ApiClient(ApiClientTests.url!)

  func testGetAsyncApi() {
    let exp = expectation(description: "Tests Get Async API")

    let request = ApiRequest(path: "posts")

    subject.fetch(request) { (result) in
      switch result {
        case .success(let response):
          do {
            let posts = try self.subject.decode(response.data!, to: [Post].self)!
            print("Received posts: \(posts.first?.title ?? "")")

            XCTAssertEqual(posts.count, 100)

            exp.fulfill()
          }
          catch {
            XCTFail("Error during decoding: \(error)")
          }
        case .failure(let error):
          XCTFail("Error during request: \(error)")
        }
    }

    waitForExpectations(timeout: 10)
  }

  func testGetApi() throws {
    let request = ApiRequest(path: "posts")

    let response = try Await.await() { handler in
      self.subject.fetch(request, handler)
    }

    if let response = response, let data = response.data,
       let posts = try self.subject.decode(data, to: [Post].self) {

      // print(try posts.prettify())

      XCTAssertEqual(posts[0].id, 1)
      XCTAssertEqual(posts.count, 100)
    }
    else {
      XCTFail("Error: empty value")
    }
  }

  func testGetDownloadApi() {
    let queue = OperationQueue()
// set maxConcurrentOperationCount to 1 so that only one operation can be run at one time
    queue.maxConcurrentOperationCount = 1

    let urls = [
      URL(string: "https://github.com/fluffyes/AppStoreCard/archive/master.zip")!,
      URL(string: "https://github.com/fluffyes/currentLocation/archive/master.zip")!,
      URL(string: "https://github.com/fluffyes/DispatchQueue/archive/master.zip")!,
      URL(string: "https://github.com/fluffyes/dynamicFont/archive/master.zip")!,
      URL(string: "https://github.com/fluffyes/telegrammy/archive/master.zip")!
    ]

    let exp = expectation(description: "Tests Get API 2")
    exp.expectedFulfillmentCount = urls.count

// call multiple urlsession downloadtask, these will all run at the same time!
    for url in urls {
      //print("start fetching \(url.absoluteString)")

//      URLSession.shared.downloadTask(with: url, completionHandler: { (tempURL, response, error) in
//        print("finished fetching \(url.absoluteString)")
//      }).resume()

//
//      let operation = BlockOperation(block: {
//        print("start fetching \(url.absoluteString)")
//        URLSession.shared.downloadTask(with: url, completionHandler: { (tempURL, response, error) in
//          print("finished fetching \(url.absoluteString)")
//        }).resume()
//      })

      let operation = DownloadOperation(session: URLSession.shared, downloadTaskURL: url, completionHandler: { (localURL, response, error) in
        print("finished downloading \(url.absoluteString)")
      })

      queue.addOperation(operation)

      exp.fulfill()
    }

    queue.waitUntilAllOperationsAreFinished()

    waitForExpectations(timeout: 10)
  }
}
