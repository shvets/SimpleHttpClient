protocol HttpFetcher {
  func fetch(_ request: ApiRequest) async -> ApiResult
}
