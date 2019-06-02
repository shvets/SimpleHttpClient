import Foundation

struct HttpHeader {
  let field: String
  let value: String
}

enum HttpMethod: String {
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case delete = "DELETE"
  case head = "HEAD"
  case options = "OPTIONS"
  case trace = "TRACE"
  case connect = "CONNECT"
}

struct ApiRequest {
  let method: HttpMethod
  let path: String

  var queryItems: [URLQueryItem] = []
  var headers: [HttpHeader]? = []
  var body: Data?
}

extension ApiRequest {
  init(method: HttpMethod = .get, path: String, queryItems: [URLQueryItem] = [], body: Data? = nil) {
    self.method = method
    self.path = path
    self.queryItems = queryItems
    self.body = body
  }
}
