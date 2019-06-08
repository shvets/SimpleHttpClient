import Foundation

open class ApiService: ApiClient {
  let apiUrl: String
  let userAgent: String

  init(apiUrl: String, userAgent: String) {
    self.apiUrl = apiUrl
    self.userAgent = userAgent

    super.init(URL(string: apiUrl)!)
  }

  func fullRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) -> T? {
    var result: T?

    var headers: [HttpHeader] = []
    headers.append(HttpHeader(field: "User-agent", value: userAgent))

    let request = ApiRequest(path: path, queryItems: params, method: method, headers: headers)

    if let apiResponse = fetch(request, to: type) {
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

    return result
  }
}
