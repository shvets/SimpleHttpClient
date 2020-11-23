protocol HttpFetcher {
  func fetch(_ request: ApiRequest, _ handler: @escaping (ApiResult) -> Void)

//  @discardableResult
//  func fetchRx(_ request: ApiRequest) -> Observable<ApiResponse>
}
