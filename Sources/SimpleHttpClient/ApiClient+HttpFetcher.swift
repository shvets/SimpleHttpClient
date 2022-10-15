import Foundation

class ApiClientOperation: Operation {
  var response: ApiResponse? = nil

  var client: ApiClient
  var request: ApiRequest

  init(client: ApiClient, request: ApiRequest) {
    self.client = client
    self.request = request
  }

  override func main() {
    let semaphore = DispatchSemaphore(value: 0)

    Task {
      let result = await client.fetch(request)

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
                      unauthorized: Bool = false) throws -> ApiResponse {
    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers, body: body)

    let operation = ApiClientOperation(client: self, request: request)

    operation.start()

    return operation.response!
  }

  public func request(_ request: ApiRequest) throws -> ApiResponse {
    let operation = ApiClientOperation(client: self, request: request)

    operation.start()

    return operation.response!
  }

  public func fetch(_ request: ApiRequest) async -> ApiResult {
    if let url = buildUrl(request) {
      do {
        let urlRequest = try buildUrlRequest(url: url, request: request)

        do {
          let (data, response) = try await session.data(for: urlRequest)

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
