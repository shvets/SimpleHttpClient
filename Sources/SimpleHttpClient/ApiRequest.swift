import Foundation

struct ApiRequest {
  let method: HttpMethod
  let path: String

  var queryItems: [URLQueryItem] = []
  var headers: [HttpHeader]? = []
  var body: Data?
}

extension ApiRequest {
  init(method: HttpMethod = .get, path: String, body: Data? = nil) {
    self.method = method
    self.path = path
    self.body = body
  }
}
