import Foundation

typealias CompletionHandler<T> = (Result<T, Error>) -> Void

//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = request.method.rawValue
//    urlRequest.httpBody = request.body
//
//    request.headers?.forEach {
//      urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
//    }

struct ApiClient {
  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetch(_ request: ApiRequest, _ completionHandler: @escaping CompletionHandler<ApiResponse>) {
    guard let url = buildUrl(request) else {
      completionHandler(.failure(ApiError.invalidURL)); return
    }

    session.dataTask(with: url, completionHandler: completionHandler).resume()
  }

  func decode<T: Decodable>(response: ApiResponse, to type: T.Type) throws -> ApiDecoded<T> {
    guard let data = response.body else {
      throw ApiError.decodingFailure
    }

    let value = try JSONDecoder().decode(T.self, from: data)

    return ApiDecoded<T>(value: value)
  }

  func buildUrl(_ request: ApiRequest) -> URL? {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path
    urlComponents.queryItems = request.queryItems

    return urlComponents.url?.appendingPathComponent(request.path)
  }
}
