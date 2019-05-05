import Foundation

typealias CompletionHandler<T> = (Result<T, Error>) -> Void

class ApiClient {
  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type,
                           _ completionHandler: @escaping CompletionHandler<T>) {
    guard let url = buildUrl(request) else {
      completionHandler(.failure(ApiError.invalidURL)); return
    }

    do {
      let urlRequest = try buildUrlRequest(url: url, request: request)

      let task = session.dataTask(with: urlRequest) { (data, response, error) in
        if let error = error {
          completionHandler(.failure(error))
        }
        else if let httpResponse = response as? HTTPURLResponse {
          let apiResponse = ApiResponse(statusCode: httpResponse.statusCode, body: data)

          if let data = apiResponse.body {
            let value = try? JSONDecoder().decode(T.self, from: data)

            if let value = value {
              completionHandler(.success(value))
            }
          }
          else {
            completionHandler(.failure(ApiError.bodyDecodingFailed))
          }
        }
        else {
          completionHandler(.failure(ApiError.notHttpResponse))
        }
      }

      task.resume()
    } catch {
      completionHandler(.failure(ApiError.bodyEncodingFailed)); return
    }
  }

  func buildUrl(_ request: ApiRequest) -> URL? {
    var urlComponents = URLComponents()

    urlComponents.scheme = baseURL.scheme
    urlComponents.host = baseURL.host
    urlComponents.path = baseURL.path
    urlComponents.queryItems = request.queryItems

    return urlComponents.url?.appendingPathComponent(request.path)
  }

  func buildUrlRequest(url: URL, request: ApiRequest) throws -> URLRequest {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue

    if let body = request.body {
      urlRequest.httpBody = try JSONEncoder().encode(body)
    }

    request.headers?.forEach {
      urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
    }

    return urlRequest
  }
}
