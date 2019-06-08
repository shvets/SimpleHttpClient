import Foundation
import RxSwift

open class EtvnetApiClient: ApiClient {
  let userAgent: String

  init(_ url: String, userAgent: String) {
    self.userAgent = userAgent

    super.init(URL(string: url)!)
  }

  func addAccessToken(params: [URLQueryItem], accessToken: String) -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []

    for param in params {
      queryItems.append(param)
    }

    queryItems.append(URLQueryItem(name: "access_token", value: accessToken))

    return queryItems
  }

//  func request<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
//                             queryItems: [URLQueryItem] = [], unauthorized: Bool=false) -> Observable<FullValue<T>> {
//    //var result: (T, ApiResponse)?
//
//    var headers: [HttpHeader] = []
//    headers.append(HttpHeader(field: "User-agent", value: userAgent))
//
//    let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers)
//
////    let semaphore = DispatchSemaphore.init(value: 0)
////
////    let disposable = fetchRx(request, to: type).subscribe(onNext: { r in
////      result = r
////
////      semaphore.signal()
////    },
////      onError: { (error) -> Void in
////        semaphore.signal()
////      })
////
////    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
////
////    disposable.dispose()
//
//    return fetchRx(request, to: type)
//  }
}
