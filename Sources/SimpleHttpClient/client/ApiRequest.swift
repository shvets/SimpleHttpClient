import Foundation

public struct HttpHeader: Hashable {
  public let field: String
  public let value: String

  public init(field: String, value: String) {
    self.field = field
    self.value = value
  }
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

public struct ApiRequest {
  let method: HttpMethod
  let path: String

  var queryItems: Set<URLQueryItem> = []
  var headers: Set<HttpHeader> = []
  var body: Data?
}

extension ApiRequest {
  public init(path: String, queryItems: Set<URLQueryItem> = [], method: HttpMethod = .get,
       headers: Set<HttpHeader> = [], body: Data? = nil) {
    self.path = path
    self.queryItems = queryItems
    self.method = method
    self.headers = headers
    self.body = body
  }
}
