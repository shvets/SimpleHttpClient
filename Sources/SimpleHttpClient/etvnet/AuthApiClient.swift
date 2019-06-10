import Foundation
import RxSwift

open class AuthApiClient: ApiClient {
  private let ClientId = "a332b9d61df7254dffdc81a260373f25592c94c9"
  private let ClientSecret = "744a52aff20ec13f53bcfd705fc4b79195265497"
  private let GrantType = "http://oauth.net/grant_type/device/1.0"

  public let Scope = [
    "com.etvnet.media.browse",
    "com.etvnet.media.watch",
    "com.etvnet.media.bookmarks",
    "com.etvnet.media.history",
    "com.etvnet.media.live",
    "com.etvnet.media.fivestar",
    "com.etvnet.media.comments",
    "com.etvnet.persons",
    "com.etvnet.notifications"
  ].joined(separator: " ")

  func getActivationUrl() -> String {
    return "\(baseURL)device/usercode"
  }
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = false) ->
    Observable<ActivationCodesProperties> {

    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "scope", value: Scope))

    if includeClientSecret {
      queryItems.append(URLQueryItem(name: "client_secret", value: ClientSecret))
    }
    
    if includeClientId {
      queryItems.append(URLQueryItem(name: "client_id", value: ClientId))
    }

    let request = ApiRequest(path: "device/code", queryItems: queryItems)

    return self.fetchRx(request).map {response in
      self.decode(response.body!, to: ActivationCodesProperties.self)!
    }
  }

  @discardableResult
  public func createToken(deviceCode: String) -> Observable<AuthProperties> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: GrantType))
    queryItems.append(URLQueryItem(name: "code", value: deviceCode))
    queryItems.append(URLQueryItem(name: "client_secret", value: ClientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: ClientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request).map {response in
      self.decode(response.body!, to: AuthProperties.self)!
    }
  }

  @discardableResult
  func updateToken(refreshToken: String) -> Observable<AuthProperties> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
    queryItems.append(URLQueryItem(name: "client_secret", value: ClientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: ClientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request).map {response in
      self.decode(response.body!, to: AuthProperties.self)!
    }
  }
}
