import Foundation

enum ApiError: Error {
  case genericError(error: Error)
  case invalidURL
  case notHttpResponse
  case bodyEncodingFailed
  case bodyDecodingFailed
  case emptyResponse
}

class ApiClient {
  private let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
  }

  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type,
                           _ handler: @escaping (Result<T, ApiError>) -> Void) {
    if let url = buildUrl(request) {
      do {
        let urlRequest = try buildUrlRequest(url: url, request: request)

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
          if let error = error {
            handler(.failure(.genericError(error: error)))
          }
          else if let httpResponse = response as? HTTPURLResponse {
            let response = ApiResponse(statusCode: httpResponse.statusCode, body: data)

            if let data = response.body {
              let value = try? JSONDecoder().decode(T.self, from: data)

              if let value = value {
                handler(.success(value))
              }
              else {
                handler(.failure(.bodyDecodingFailed))
              }
            }
            else {
              handler(.failure(.emptyResponse))
            }
          }
          else {
            handler(.failure(.notHttpResponse))
          }
        }

        task.resume()
      } catch {
        handler(.failure(.bodyEncodingFailed))
      }
    }
    else {
      handler(.failure(.invalidURL))
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
