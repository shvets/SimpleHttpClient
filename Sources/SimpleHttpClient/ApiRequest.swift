import Foundation

struct ApiRequest {
  let method: HttpMethod
  let path: String

  var queryItems: [URLQueryItem] = []
  var headers: [HttpHeader]? = []
  var body: Data?

  init(method: HttpMethod = .get, path: String) {
    self.method = method
    self.path = path
  }

  init<Body: Encodable>(method: HttpMethod = .get, path: String, body: Body) throws {
    self.method = method
    self.path = path

    self.body = try JSONEncoder().encode(body)
  }
}