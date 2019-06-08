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

protocol HttpFetcher {
  func fetchAsync<T: Decodable>(_ request: ApiRequest, to type: T.Type,
                           _ handler: @escaping (Result<T, ApiError>) -> Void)

  @discardableResult
  func fetchRx<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> Observable<T>

  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> T?
}

open class ApiClient {
  private let baseURL: URL
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

  static func await0<T: Decodable>(_ handler: @escaping () -> Result<T, ApiError>) -> Result<T, ApiError> {
    let semaphore = DispatchSemaphore.init(value: 0)

    let result: Result<T, ApiError> = handler()

    semaphore.signal()

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return result
  }

  @discardableResult
  static func await<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let disposable = handler().subscribe(onNext: { response in
      result = response
      semaphore.signal()
    },
      onError: { (e) -> Void in
        error = e
        semaphore.signal()
      }
    )

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    disposable.dispose()

    if let error = error {
      throw error
    }

    return result
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
              do {
                let decoder = JSONDecoder()

                let value = try decoder.decode(T.self, from: data)

                handler(.success(value))
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
  func fetchRx<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> Observable<T> {
    return Observable.create { observer -> Disposable in
      if let url = self.buildUrl(request) {
        do {
          let urlRequest = try self.buildUrlRequest(url: url, request: request)

          let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
              observer.onError(ApiError.genericError(error: error))
            }
            else if let httpResponse = response as? HTTPURLResponse {
              //let response = ApiResponse(statusCode: httpResponse.statusCode, body: data)

              if let data = data {
                do {
                  let decoder = JSONDecoder()

                  let value = try decoder.decode(T.self, from: data)

                  observer.on(.next(value))
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

  @discardableResult
  func fetch<T: Decodable>(_ request: ApiRequest, to type: T.Type) -> T? {
    var result: T?

    let semaphore = DispatchSemaphore.init(value: 0)

    _ = fetchRx(request, to: type).subscribe(onNext: { response in
      result = response

      semaphore.signal()
    },
    onError: { (error) -> Void in
      semaphore.signal()
    })

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return result
  }
}
