import Foundation

public struct HttpHeader: Hashable {
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

  var queryItems: Set<URLQueryItem> = []
  var headers: Set<HttpHeader> = []
  var body: Data?
}

extension ApiRequest {
  init(path: String, queryItems: Set<URLQueryItem> = [], method: HttpMethod = .get,
       headers: Set<HttpHeader> = [], body: Data? = nil) {
    self.path = path
    self.queryItems = queryItems
    self.method = method
    self.headers = headers
    self.body = body
  }
}
