import Foundation
import RxSwift

open class AuthService: ApiClient {
  public var authorizeCallback: () -> Void = {}

  var config: ConfigFile<String>!

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

  public func setConfig(config: ConfigFile<String>) {
    self.config = config
  }

  func getActivationUrl() -> String {
    return "\(authUrl)device/usercode"
  }

  public func authorize(authorizeCallback: @escaping () -> Void) {
    self.authorizeCallback = authorizeCallback
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

    let request = ApiRequest(path: "device/code", queryItems: queryItems)

    return self.fetchRx(request, to: ActivationCodesProperties.self)
  }

  @discardableResult
  public func createToken(deviceCode: String) -> Observable<AuthProperties> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: grantType))
    queryItems.append(URLQueryItem(name: "code", value: deviceCode))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request, to: AuthProperties.self)
  }

  @discardableResult
  func updateToken(refreshToken: String) -> Observable<AuthProperties> {
    var queryItems: [URLQueryItem] = []

    queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
    queryItems.append(URLQueryItem(name: "client_secret", value: clientSecret))
    queryItems.append(URLQueryItem(name: "client_id", value: clientId))

    let request = ApiRequest(path: "token", queryItems: queryItems)

    return self.fetchRx(request, to: AuthProperties.self)
  }

  func checkAccessData(_ key: String) -> Bool {
    if key == "device_code" {
      return (config.items[key] != nil)
    }
    else {
      return (config.items[key] != nil) && (config.items["expires"] != nil) &&
        config.items["expires"]! >= String(Int(Date().timeIntervalSince1970))
    }
  }

  public func checkToken() -> Bool {
    var ok = false

    if checkAccessData("access_token") {
      ok = true
    }
    else if config.items["refresh_token"] != nil {
      let refreshToken = config.items["refresh_token"]

      if let refreshToken = refreshToken, tryUpdateToken(refreshToken: refreshToken) {
        ok = true
      }
    }
    else if checkAccessData("device_code") {
      let deviceCode = config.items["device_code"]

      do {
        if let deviceCode = deviceCode,
           let response = try await({ self.createToken(deviceCode: deviceCode) }) {

          self.config.items = response.asConfigurationItems()
          //self.saveConfig()
        }
      }
      catch {
        print(error)
      }
    }

    return ok
  }

  func tryUpdateToken(refreshToken: String) -> Bool {
    var ok = false

    do {
      if let response = try await({ self.updateToken(refreshToken: refreshToken) }) {
        self.config.items = response.asConfigurationItems()
        //self.saveConfig()

        ok = true
      }
    }
    catch {
      print(error)
    }

    return ok
  }
}
