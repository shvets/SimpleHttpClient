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

  func buildUrl(_ baseURL: URL) -> URL? {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path
    urlComponents.queryItems = queryItems

    return urlComponents.url?.appendingPathComponent(path)
  }
}
