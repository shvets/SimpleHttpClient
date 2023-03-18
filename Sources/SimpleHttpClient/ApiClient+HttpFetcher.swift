import Foundation

class ApiClientOperation: Operation {
  var response: ApiResponse? = nil

  var client: ApiClient
  var request: ApiRequest
  var delegate: URLSessionTaskDelegate?

  init(client: ApiClient, request: ApiRequest, delegate: URLSessionTaskDelegate? = nil) {
    self.client = client
    self.request = request
    self.delegate = delegate
  }

  override func main() {
    let semaphore = DispatchSemaphore(value: 0)

    Task {
      let result = await client.fetch(request, delegate: delegate)

      switch result {
        case .success(let r):
          response = r

        case .failure(let error):
          throw error
      }

      semaphore.signal()
    }

    semaphore.wait()
  }
}

extension ApiClient: HttpFetcher {
  public func request(_ path: String = "", method: HttpMethod = .get,
                      queryItems: Set<URLQueryItem> = [], headers: Set<HttpHeader> = [],
                      body: Data? = nil,
                      unauthorized: Bool = false,
                      delegate: URLSessionTaskDelegate? = nil) throws -> ApiResponse {
    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers, body: body)

    let operation = ApiClientOperation(client: self, request: request, delegate: delegate)

    operation.start()

    return operation.response!
  }

  public func request(_ request: ApiRequest) throws -> ApiResponse {
    let operation = ApiClientOperation(client: self, request: request)

    operation.start()

    return operation.response!
  }

  public func requestAsync(_ path: String = "", method: HttpMethod = .get,
                      queryItems: Set<URLQueryItem> = [], headers: Set<HttpHeader> = [],
                      body: Data? = nil,
                      unauthorized: Bool = false,
                      delegate: URLSessionTaskDelegate? = nil) async throws -> ApiResponse {
    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers, body: body)

    let result = await fetch(request, delegate: delegate)

    switch result {
    case .success(let r):
      return r

    case .failure(let error):
      throw error
    }
  }

  public func requestAsync(_ request: ApiRequest) async throws -> ApiResponse {
    let result = await fetch(request, delegate: nil)

    switch result {
    case .success(let r):
      return r

    case .failure(let error):
      throw error
    }
  }

  public func fetch(_ request: ApiRequest, delegate: URLSessionTaskDelegate? = nil) async -> ApiResult {
    if let url = buildUrl(request) {
      do {
        let urlRequest = try buildUrlRequest(url: url, request: request)

        do {
          let (data, response) = try await session.data(for: urlRequest, delegate: delegate)

          if let httpResponse = response as? HTTPURLResponse {
            let response = ApiResponse(data: data, response: httpResponse)

            return .success(response)
          } else {
            return .failure(.notHttpResponse)
          }
        }
        catch {
          return .failure(.genericError(error: error))
        }
      }
      catch {
        return .failure(.bodyEncodingFailed)
      }
    }
    else {
      return .failure(.invalidURL)
    }
  }
}
