import Foundation

typealias CompletionHandler<T> = (Result<T, Error>) -> Void

typealias DataAPIResponse = ApiResponse<Data?>

extension URLSession {
  func dataTask(with url: URL, completionHandler: @escaping CompletionHandler<DataAPIResponse>) ->
    URLSessionDataTask {
    return dataTask(with: url) { (data, response, error) in
      if let error = error {
        completionHandler(.failure(error))
      }
      else if let httpResponse = response as? HTTPURLResponse {
        let result = DataAPIResponse(statusCode: httpResponse.statusCode, body: data)

        completionHandler(.success(result))
      }
      else {
        completionHandler(.failure(ApiError.requestFailed))
      }
    }
  }
}

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

  func fetch(method: HttpMethod = .get, path: String = "", queryItems: [URLQueryItem] = [],
             _ completionHandler: @escaping CompletionHandler<DataAPIResponse>) {
    guard let url = buildUrl(baseURL, path: path, queryItems: queryItems) else {
      completionHandler(.failure(ApiError.invalidURL)); return
    }

    session.dataTask(with: url, completionHandler: completionHandler).resume()
  }

  func decode<T: Decodable>(response: DataAPIResponse, to type: T.Type) throws -> ApiResponse<T> {
    guard let data = response.body else {
      throw ApiError.decodingFailure
    }

    let decodedJSON = try JSONDecoder().decode(T.self, from: data)

    return ApiResponse<T>(statusCode: response.statusCode, body: decodedJSON)
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
