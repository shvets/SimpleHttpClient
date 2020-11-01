import Foundation

open class ApiClient {
  public let baseURL: URL
  let session: URLSession

  public init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func buildUrl(_ request: ApiRequest) -> URL? {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path

    if !request.queryItems.isEmpty {
      urlComponents.queryItems = Array(request.queryItems)
    }

    if request.path.isEmpty {
      return urlComponents.url
    }
    else {
      return urlComponents.url?.appendingPathComponent(request.path)
    }
  }

  func buildUrlRequest(url: URL, request: ApiRequest) throws -> URLRequest {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue

    if let body = request.body {
      urlRequest.httpBody = body
    }

    request.headers.forEach {
      urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
    }

    return urlRequest
  }
}
