import Foundation

extension URLSession {
  func dataTask(with url: URL, completionHandler: @escaping CompletionHandler<ApiResponse>) ->
    URLSessionDataTask {
    return dataTask(with: url) { (data, response, error) in
      self.handle(data: data, response: response, error: error, completionHandler: completionHandler)
    }
  }

  func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler<ApiResponse>) ->
    URLSessionDataTask {
    return dataTask(with: request) { (data, response, error) in
      self.handle(data: data, response: response, error: error, completionHandler: completionHandler)
    }
  }

  func handle(data: Data?, response: URLResponse?, error: Error?,
              completionHandler: @escaping CompletionHandler<ApiResponse>) {
    if let error = error {
      completionHandler(.failure(error))
    }
    else if let httpResponse = response as? HTTPURLResponse {
      let result = ApiResponse(statusCode: httpResponse.statusCode, body: data)

      completionHandler(.success(result))
    }
    else {
      completionHandler(.failure(ApiError.requestFailed))
    }
  }
}