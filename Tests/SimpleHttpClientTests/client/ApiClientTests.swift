import XCTest

import Foundation

@testable import SimpleHttpClient

class ApiClientTests: XCTestCase {
  static let url = URL(string: "https://jsonplaceholder.typicode.com")

  var subject = ApiClient(ApiClientTests.url!)

  func testGetApi() {
    struct Post: Codable {
      let userId: Int
      let id: Int
      let title: String
      let body: String
    }

    let exp = expectation(description: "Tests Get API")

    let request = ApiRequest(path: "posts")

    subject.fetch(request, to: [Post].self) { (result) in
      switch result {
      case .success(let posts):
        print("Received posts: \(posts.first?.title ?? "")")

        XCTAssertEqual(posts.count, 100)

        exp.fulfill()
      case .failure(let error):
        XCTFail("Error during request: \(error)")
      }
    }

    waitForExpectations(timeout: 10)
  }

  func testGetApi2() {
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
