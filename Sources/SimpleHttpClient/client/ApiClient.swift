import Foundation

public enum ApiError: Error {
  case genericError(error: Error)
  case invalidURL
  case notHttpResponse
  case bodyEncodingFailed
  case bodyDecodingFailed
}

protocol HttpFetcher {
  func fetch(_ request: ApiRequest, _ handler: @escaping (Result<ApiResponse, ApiError>) -> Void)

//  @discardableResult
//  func fetchRx(_ request: ApiRequest) -> Observable<ApiResponse>
}

open class ApiClient {
  public let baseURL: URL
  private let session: URLSession

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

extension ApiClient: HttpFetcher {
  public func fetch(_ request: ApiRequest, _ handler: @escaping (Result<ApiResponse, ApiError>) -> Void) {
    if let url = buildUrl(request) {
      do {
        let urlRequest = try buildUrlRequest(url: url, request: request)

        let task = session.dataTask(with: urlRequest) { (data, response, error) in
          if let error = error {
            handler(.failure(.genericError(error: error)))
          }
          else if let httpResponse = response as? HTTPURLResponse {
            let response = ApiResponse(data: data, response: httpResponse)

            handler(.success(response))
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

//  @discardableResult
//  public func fetchRx(_ request: ApiRequest) -> Observable<ApiResponse> {
//    return Observable.create { observer -> Disposable in
//      if let url = self.buildUrl(request) {
//        do {
//          let urlRequest = try self.buildUrlRequest(url: url, request: request)
//          // print("\(urlRequest.httpMethod!): \(url)")
//
//          let task = self.session.dataTask(with: urlRequest) { (data, response, error) in
//            if let error = error {
//              observer.onError(ApiError.genericError(error: error))
//            }
//            else if let httpResponse = response as? HTTPURLResponse {
//              let response = ApiResponse(data: data, response: httpResponse)
//
//              //print("Result: \(String(data: data, encoding: .utf8)!)")
//
//              observer.on(.next(response))
//              observer.on(.completed)
//            }
//            else {
//              observer.on(.error(ApiError.notHttpResponse))
//            }
//          }
//
//          task.resume()
//        } catch {
//          print(error)
//          observer.on(.error(ApiError.bodyEncodingFailed))
//        }
//      }
//      else {
//        observer.on(.error(ApiError.invalidURL))
//      }
//
//      return Disposables.create()
//    }
//  }

  public func request(_ path: String = "", method: HttpMethod = .get,
                      queryItems: Set<URLQueryItem> = [], headers: Set<HttpHeader> = [],
                      body: Data? = nil,
                      unauthorized: Bool=false) throws -> ApiResponse? {
    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers, body: body)

    return try Await.await() { handler in
      self.fetch(request, handler)
    }
  }

//  public func requestRx(_ path: String = "", method: HttpMethod = .get,
//                      queryItems: Set<URLQueryItem> = [], headers: Set<HttpHeader> = [],
//                      body: Data? = nil,
//                      unauthorized: Bool=false) throws -> ApiResponse? {
//    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers, body: body)
//
//    return try Await.awaitRx {
//      self.fetchRx(request)
//    }
//  }

  public func decode<T: Decodable>(_ data: Data, to type: T.Type, decoder: JSONDecoder = .init() ) throws -> T? {
    var value: T? = nil

    if !data.isEmpty {
      value = try decoder.decode(T.self, from: data)
    }

    return value
  }

//  @discardableResult
//  public func awaitRx<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
//    return try Await.awaitRx(handler)
//  }
}
