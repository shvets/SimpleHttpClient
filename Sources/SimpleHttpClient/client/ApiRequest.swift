import Foundation

public struct HttpHeader {
  let field: String
  let value: String
}

public enum HttpMethod: String {
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case patch = "PATCH"
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
  var headers: [HttpHeader] = []
  var body: Data?
}

extension ApiRequest {
  init(path: String, queryItems: [URLQueryItem] = [], method: HttpMethod = .get,
       headers: [HttpHeader] = [], body: Data? = nil) {
    self.path = path
    self.queryItems = queryItems
    self.method = method
    self.headers = headers
    self.body = body
  }
}
