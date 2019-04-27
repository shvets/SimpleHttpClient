import Foundation

struct APIClient {

  typealias APIClientCompletion = (APIResult<Data?>) -> Void

  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func perform(_ request: APIRequest, _ completion: @escaping APIClientCompletion) {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path
    urlComponents.queryItems = request.queryItems

    guard let url = urlComponents.url?.appendingPathComponent(request.path) else {
      completion(.failure(.invalidURL)); return
    }

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue
    urlRequest.httpBody = request.body

    request.headers?.forEach { urlRequest.addValue($0.value, forHTTPHeaderField: $0.field) }

    let task = session.dataTask(with: url) { (data, response, error) in
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(.requestFailed)); return
      }

      completion(.success(APIResponse<Data?>(statusCode: httpResponse.statusCode, body: data)))
    }

    task.resume()
  }
}
