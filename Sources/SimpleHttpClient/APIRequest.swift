import Foundation

class APIRequest {
  let method: HttpMethod
  let path: String
  var queryItems: [URLQueryItem]?
  var headers: [HttpHeader]?
  var body: Data?

  init(method: HttpMethod, path: String) {
      self.method = method
      self.path = path
  }

  init<Body: Encodable>(method: HttpMethod, path: String, body: Body) throws {
      self.method = method
      self.path = path
      self.body = try JSONEncoder().encode(body)
  }
}
