import XCTest

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

  func testGetApi() {
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

    waitForExpectations(timeout: 10, handler: nil)
  }
}
