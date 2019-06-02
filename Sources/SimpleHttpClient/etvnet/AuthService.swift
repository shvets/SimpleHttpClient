import Foundation
import RxSwift

open class AuthService: HttpService {
  var authUrl: String
  var clientId: String
  var clientSecret: String
  var grantType: String
  var scope: String

  init(authUrl: String, clientId: String, clientSecret: String, grantType: String, scope: String) {
    self.authUrl = authUrl
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.grantType = grantType
    self.scope = scope
  }

  func getActivationUrl() -> String {
    return "\(authUrl)device/usercode"
  }
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) ->
    Observable<ActivationCodesProperties> {

    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "scope", value: scope))

    if includeClientSecret {
      queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    }
    
    if includeClientId {
      queryItems.append(URLQueryItem(name: "client_id", value: clientId))
    }

    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let url = URL(string: authUrl)

    let client = ApiClient(url!)

    let request = ApiRequest(path: "device/code", queryItems: queryItems)

    return client.fetch(request, to: ActivationCodesProperties.self)
  }
  
  public func createToken(deviceCode: String) -> Observable<AuthProperties> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: grantType))
    queryItems.append(URLQueryItem(name: "code", value: deviceCode))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let url = URL(string: authUrl)

    let client = ApiClient(url!)

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return client.fetch(request, to: AuthProperties.self)
  }
  
  func updateToken(refreshToken: String) -> Observable<AuthProperties> {
    var result: AuthProperties?

    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let url = URL(string: authUrl)

    let client = ApiClient(url!)

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return client.fetch(request, to: AuthProperties.self)
  }
}
