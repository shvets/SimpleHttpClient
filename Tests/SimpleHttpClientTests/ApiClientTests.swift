import XCTest

@testable import SimpleHttpClient

struct Post: Decodable {
  let userId: Int
  let id: Int
  let title: String
  let body: String
}

class ApiClientTests: XCTestCase {

  var subject = APIClient(URL(string: "https://jsonplaceholder.typicode.com")!)

//  func testApi1() {
//    let request = APIRequest(method: .post, path: "posts")
//    request.queryItems = [URLQueryItem(name: "hello", value: "world")]
//    request.headers = [HTTPHeader2(field: "Content-Type", value: "application/json")]
//    request.body = Data() // example post body
//
//    subject.perform(request) { (_, data, _) in
//      print(data as! Data)
//      if let data = data, let result = String(data: data, encoding: .utf8) {
//        print(result)
//      }
//    }
//
////    print(result)
//  }

  func testApi() {
    let request = APIRequest(method: .get, path: "posts")

    subject.perform(request) { (result) in
      print(result)
      switch result {
        case .success(let response):
          if let response = try? response.decode(to: [Post].self) {
            let posts = response.body
            print("Received posts: \(posts.first?.title ?? "")")
          } else {
            print("Failed to decode response")
          }
        case .failure:
          print("Error perform network request")
      }
    }
  }
}
