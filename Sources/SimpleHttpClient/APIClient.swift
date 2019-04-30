import Foundation

typealias APICompletionHandler<T> = (Result<T, Error>) -> Void

struct APIClient {
  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetch(_ request: APIRequest, _ completionHandler: @escaping APICompletionHandler<APIResponse<Data?>>) {
    guard let url = request.buildUrl(baseURL) else {
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
}
