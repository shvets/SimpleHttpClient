import Foundation
import RxSwift

enum ApiError: Error {
  case genericError(error: Error)
  case invalidURL
  case notHttpResponse
  case bodyEncodingFailed
  case bodyDecodingFailed
  case emptyResponse
}

public typealias FullValue<T> = (value: T, response: ApiResponse)

protocol HttpFetcher {
  func fetchAsync<T: Decodable>(_ request: ApiRequest, to type: T.Type,
                           _ handler: @escaping (Result<FullValue<T>, ApiError>) -> Void)

  @discardableResult
  func fetchRx<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> Observable<FullValue<T>>

  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type) throws -> FullValue<T>?
}

open class ApiClient {
  let baseURL: URL
  private let session: URLSession

  init(_ baseURL: URL, session: URLSession = URLSession.shared) {
    self.baseURL = baseURL
    self.session = session
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
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted

      urlRequest.httpBody = try encoder.encode(body)
    }

    request.headers.forEach {
      urlRequest.addValue($0.value, forHTTPHeaderField: $0.field)
    }

    return urlRequest
  }
}

extension ApiClient: HttpFetcher {
  func fetchAsync<T: Decodable>(_ request: ApiRequest, to type: T.Type,
                                _ handler: @escaping (Result<FullValue<T>, ApiError>) -> Void) {
    if let url = buildUrl(request) {
      do {
        let urlRequest = try buildUrlRequest(url: url, request: request)

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
          if let error = error {
            handler(.failure(.genericError(error: error)))
          }
          else if let httpResponse = response as? HTTPURLResponse {
            if let data = data {
              do {
                let value: T

                let response = ApiResponse(statusCode: httpResponse.statusCode, body: data)

                if data.isEmpty {
                  value = "" as! T
                }
                else {
                  let decoder = JSONDecoder()

                  value = try decoder.decode(T.self, from: data)
                }

                handler(.success((value, response)))
              }
              catch {
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

  @discardableResult
  func fetchRx<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> Observable<FullValue<T>> {
    return Observable.create { observer -> Disposable in
      if let url = self.buildUrl(request) {
        do {
          let urlRequest = try self.buildUrlRequest(url: url, request: request)

          let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
              observer.onError(ApiError.genericError(error: error))
            }
            else if let httpResponse = response as? HTTPURLResponse {
              if let data = data {
                do {
                  print("Result: \(String(data: data, encoding: .utf8)!)")

                  let value: T

                  let response = ApiResponse(statusCode: httpResponse.statusCode, body: data)

                  if data.isEmpty {
                    value = "" as! T
                  }
                  else {
                    let decoder = JSONDecoder()

                    value = try decoder.decode(T.self, from: data)
                  }

                  observer.on(.next((value, response)))
                  observer.on(.completed)
                }
                catch {
                  observer.on(.error(ApiError.bodyDecodingFailed))
                }
              }
              else {
                observer.on(.error(ApiError.emptyResponse))
              }
            }
            else {
              observer.on(.error(ApiError.notHttpResponse))
            }
          }

          task.resume()
        } catch {
          observer.on(.error(ApiError.bodyEncodingFailed))
        }
      }
      else {
        observer.on(.error(ApiError.invalidURL))
      }

      return Disposables.create()
    }
  }

  func decode<T: Decodable>(_ data: Data, to type: T.Type) -> T? {
    var value: T?

    do {
      if data.isEmpty {
        value = "" as! T
      }
      else {
        let decoder = JSONDecoder()

        value = try decoder.decode(T.self, from: data)
      }
    }
    catch {
      print(error)
    }

    return value
  }

  @discardableResult
  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type) throws -> FullValue<T>? {
    return try await {
      self.fetchRx(request, to: type)
    }
  }

  @discardableResult
  func await<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
    return try Await.await(handler)
  }
}
