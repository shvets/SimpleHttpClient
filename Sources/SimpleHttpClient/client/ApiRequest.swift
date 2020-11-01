import Foundation

public struct ApiRequest {
  let method: HttpMethod
  let path: String

  var queryItems: Set<URLQueryItem> = []
  var headers: Set<HttpHeader> = []
  var body: Data?

  public init(path: String, queryItems: Set<URLQueryItem> = [], method: HttpMethod = .get,
       headers: Set<HttpHeader> = [], body: Data? = nil) {
    self.path = path
    self.queryItems = queryItems
    self.method = method
    self.headers = headers
    self.body = body
  }
}
