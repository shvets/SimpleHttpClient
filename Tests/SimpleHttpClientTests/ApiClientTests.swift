import XCTest

import Foundation

@testable import SimpleHttpClient

struct Post: Codable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}

class ApiClientTests: XCTestCase, URLSessionDelegate {
  static let url = URL(string: "https://jsonplaceholder.typicode.com")

  var subject = ApiClient(ApiClientTests.url!)

  func testGetAsyncApi() async {
    let request = ApiRequest(path: "posts")

    let result = await subject.fetch(request)

    switch result {
      case .success(let response):
        do {
          let posts = try self.subject.decode(response.data!, to: [Post].self)!
          print("Received posts: \(posts.first?.title ?? "")")

          XCTAssertEqual(posts.count, 100)
        }
        catch {
          XCTFail("Error during decoding: \(error)")
        }
      case .failure(let error):
        XCTFail("Error during request: \(error)")
      }
  }

  func testGetApi() async throws {
    let request = ApiRequest(path: "posts")

    let result = try await subject.fetch(request)

    if case .success(let response) = result, let data = response.data,
       let posts = try subject.decode(data, to: [Post].self) {

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
//
//  // https://kinotochka.co/index.php?newsid=7596
//  func testClient() async throws {
//    let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
//
//    let apiClient = ApiClient(URL(string: "https://kinotochka.co")!, session: session)
//
//    let url = "/index.php"
//
//    var headers: Set<HttpHeader> = []
//    headers.insert(HttpHeader(field: "Host", value: "kinotochka.co"))
//    headers.insert(HttpHeader(field: "user-agent", value: "curl/7.79.1"))
//    //headers.insert(HttpHeader(field: "accept", value: "*/*"))
//    //headers.insert(HttpHeader(field: " Content-Type", value: "text/json"))
//
//    var queryItems: Set<URLQueryItem> = []
//    queryItems.insert(URLQueryItem(name: "newsid", value: "7596"))
//
//    if let response = try! apiClient.request(url, queryItems: queryItems, headers: headers) {
//      //"\(KinoTochkaApiService.SiteUrl)\(url)") {
//      print(response.response.statusCode)
//      print(String(data: response.data!, encoding: .utf8))
//      //document = try data.toDocument(encoding: encoding)
//    }
//  }
//
//  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//    if challenge.protectionSpace.host == "kinotochka.co" {
//      completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
//    } else {
//      completionHandler(.performDefaultHandling, nil)
//    }
//  }
}
