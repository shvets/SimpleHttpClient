import XCTest

@testable import SimpleHttpClient

struct Post: Decodable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}

class ApiClientTests: XCTestCase {
  static let url = URL(string: "https://jsonplaceholder.typicode.com")

  var subject = APIClient(ApiClientTests.url!)

  func testGetApi() {
    let exp = expectation(description: "Tests Get API")

    subject.fetch(method: .get, path: "posts") { (result) in
      switch result {
        case .success(let response):
          if let response = try? self.subject.decode(response: response, to: [Post].self) {
            let posts = response.body

            print("Received posts: \(posts.first?.title ?? "")")

            XCTAssertEqual(posts.count, 100)

            exp.fulfill()
          } else {
            XCTFail("Failed to decode response")
          }
        case .failure:
          XCTFail("Error perform network request")
      }
    }

    waitForExpectations(timeout: 10, handler: nil)
  }
}
