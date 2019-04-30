import Foundation

typealias APICompletionHandler<T> = (Result<T, Error>) -> Void

struct APIClient {
  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetch(method: HttpMethod = .get, path: String = "", queryItems: [URLQueryItem] = [],
             _ completionHandler: @escaping APICompletionHandler<APIResponse<Data?>>) {
    guard let url = buildUrl(baseURL, path: path, queryItems: queryItems) else {
      completionHandler(.failure(APIError.invalidURL)); return
    }

//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = request.method.rawValue
//    urlRequest.httpBody = request.body
//
//    request.headers?.forEach {
//      urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
//    }

    let task = session.dataTask(with: url) { (data, response, error) in
      guard let httpResponse = response as? HTTPURLResponse else {
        completionHandler(.failure(APIError.requestFailed)); return
      }

      completionHandler(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
    }

    task.resume()
  }

  func buildUrl(_ baseURL: URL, path: String, queryItems: [URLQueryItem]) -> URL? {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path
    urlComponents.queryItems = queryItems

    return urlComponents.url?.appendingPathComponent(path)
  }
}
