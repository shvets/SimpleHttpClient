import Foundation

protocol HttpFetcher {
  func fetch(_ request: ApiRequest, delegate: URLSessionTaskDelegate?) async -> ApiResult
}
