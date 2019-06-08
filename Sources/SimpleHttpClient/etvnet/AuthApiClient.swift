import Foundation
import RxSwift

open class AuthApiClient: ApiClient {
  let authUrl: String
  let clientId: String
  let clientSecret: String
  let grantType: String
  let scope: String

  init(authUrl: String, clientId: String, clientSecret: String, grantType: String, scope: String) {
    self.authUrl = authUrl
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.grantType = grantType
    self.scope = scope

    super.init(URL(string: authUrl)!)
  }

  func getActivationUrl() -> String {
    return "\(authUrl)device/usercode"
  }
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) ->
    Observable<(ActivationCodesProperties, ApiResponse)> {

    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "scope", value: scope))

    if includeClientSecret {
      queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    }
    
    if includeClientId {
      queryItems.append(URLQueryItem(name: "client_id", value: clientId))
    }

    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let request = ApiRequest(path: "device/code", queryItems: queryItems)

    return self.fetchRx(request, to: ActivationCodesProperties.self)
  }

  @discardableResult
  public func createToken(deviceCode: String) -> Observable<(AuthProperties, ApiResponse)> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: grantType))
    queryItems.append(URLQueryItem(name: "code", value: deviceCode))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request, to: AuthProperties.self)
  }

  @discardableResult
  func updateToken(refreshToken: String) -> Observable<(AuthProperties, ApiResponse)> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request, to: AuthProperties.self)
  }
}