import Foundation
import RxSwift

open class ApiService: ApiClient {
  //public var config: ConfigFile<String>!

  let apiUrl: String
  let userAgent: String
  //var authService: AuthService!

  init(apiUrl: String, userAgent: String) {
    self.apiUrl = apiUrl
    self.userAgent = userAgent

    super.init(URL(string: apiUrl)!)
  }

//  public func setAuth(authService: AuthService) {
//    self.authService = authService
//  }

  func fullRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) -> T? {
    var result: T?

//    if !authService.checkToken() {
//      authService.authorizeCallback()
//    }
//
//    if let accessToken = config.items["access_token"] {
//      var queryItems: [URLQueryItem] = []
//
//      for param in params {
//        queryItems.append(param)
//      }
//
//      queryItems.append(URLQueryItem(name: "access_token", value: accessToken))

        var headers: [HttpHeader] = []
        headers.append(HttpHeader(field: "User-agent", value: userAgent))

        if let apiResponse = httpRequest(path: path, to: type, method: method, queryItems: params,
          headers: headers) {

          result = apiResponse

          // todo
           //let statusCode = apiResponse.response?.statusCode {
//          if (statusCode == 401 || statusCode == 400) && !unauthorized {
//            let refreshToken = config.items["refresh_token"]
//
//            if let refreshToken = refreshToken, tryUpdateToken(refreshToken: refreshToken) {
//              response = fullRequest(path: path, method: method, parameters: parameters, unauthorized: true)
//            }
//            else {
//              print("error")
//            }
//          }
//          else {
//            response = apiResponse
//          }
        }
   // }

    return result
  }

  public func httpRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                        queryItems: [URLQueryItem] = [], headers: [HttpHeader] = []) -> T? {
    //var result: T?

    let client = ApiClient(URL(string: apiUrl)!)

    let request = ApiRequest(path: path, queryItems: queryItems, headers: headers)

//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    let disposable = client.fetchRx(request, to: type).subscribe(onNext: { response in
//      result = response
//      semaphore.signal()
//    },
//      onError: { (e) -> Void in
//        //error = e
//        semaphore.signal()
//      }
//    )
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//    disposable.dispose()

    return client.fetch(request, to: type)
  }

}
