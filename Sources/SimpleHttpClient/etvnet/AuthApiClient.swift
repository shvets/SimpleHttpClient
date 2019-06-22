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
  
  func getActivationCodes(includeClientSecret: Bool = true, includeClientId: Bool = true) ->
    Observable<ActivationCodesProperties?> {

    var queryItems: Set<URLQueryItem> = []

    queryItems.insert(URLQueryItem(name: "scope", value: Scope))

    if includeClientSecret {
      queryItems.insert(URLQueryItem(name: "client_secret", value: ClientSecret))
    }
    
    if includeClientId {
      queryItems.insert(URLQueryItem(name: "client_id", value: ClientId))
    }

    let request = ApiRequest(path: "device/code", queryItems: queryItems)

    return self.fetchRx(request).map { response in
      if let body = response.data {
        return try self.decode(body, to: ActivationCodesProperties.self)!
      }
      else {
        return nil
      }
    }
  }

  @discardableResult
  public func createToken(deviceCode: String) -> Observable<AuthProperties?> {
    var queryItems: Set<URLQueryItem> = []

    queryItems.insert(URLQueryItem(name: "grant_type", value: GrantType))
    queryItems.insert(URLQueryItem(name: "code", value: deviceCode))
    queryItems.insert(URLQueryItem(name: "client_secret", value: ClientSecret))
    queryItems.insert(URLQueryItem(name: "client_id", value: ClientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request).map { response in
      if let body = response.data {
        return try self.decode(body, to: AuthProperties.self)!
      }
      else {
        return nil
      }
    }
  }

  @discardableResult
  func updateToken(refreshToken: String) -> Observable<AuthProperties?> {
    var queryItems: Set<URLQueryItem> = []

    queryItems.insert(URLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.insert(URLQueryItem(name: "refresh_token", value: refreshToken))
    queryItems.insert(URLQueryItem(name: "client_secret", value: ClientSecret))
    queryItems.insert(URLQueryItem(name: "client_id", value: ClientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request).map { response in
      if let body = response.data {
        return try self.decode(body, to: AuthProperties.self)!
      }
      else {
        return nil
      }
    }
  }
}
