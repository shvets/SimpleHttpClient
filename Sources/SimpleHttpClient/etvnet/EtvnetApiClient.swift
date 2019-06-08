import Foundation
import RxSwift

open class EtvnetApiClient: ApiClient {
  public let ClientId = "a332b9d61df7254dffdc81a260373f25592c94c9"
  public let ClientSecret = "744a52aff20ec13f53bcfd705fc4b79195265497"

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

  public let GrantType = "http://oauth.net/grant_type/device/1.0"

  public var config: ConfigFile<String>!

  let authClient: AuthApiClient!

  public var authorizeCallback: () -> Void = {
  }

  init(_ url: String, authUrl: String) {
    authClient = AuthApiClient(authUrl: authUrl, clientId: ClientId, clientSecret: ClientSecret,
      grantType: GrantType, scope: Scope)

    super.init(URL(string: url)!)
  }

  public func authorize(authorizeCallback: @escaping () -> Void) {
    self.authorizeCallback = authorizeCallback
  }
}

extension EtvnetApiClient {
  func loadConfig(config: ConfigFile<String>) {
    self.config = config

    if (config.exists()) {
      do {
        try ApiClient.await {
          self.config.read()
        }
      } catch {
        print(error)
      }
    }
  }

  func saveConfig() {
    do {
      try ApiClient.await({ self.config.write() })
    } catch {
      print(error)
    }
  }
}

extension EtvnetApiClient {
  public func resetToken() {
    _ = config.remove("access_token")
    _ = config.remove("refresh_token")
    _ = config.remove("device_code")
    _ = config.remove("user_code")
    _ = config.remove("activation_url")

    saveConfig()
  }

  func addAccessToken(params: [URLQueryItem], accessToken: String) -> [URLQueryItem] {
    var queryItems: [URLQueryItem] = []

    for param in params {
      queryItems.append(param)
    }

    queryItems.append(URLQueryItem(name: "access_token", value: accessToken))

    return queryItems
  }

  public func authorization(includeClientSecret: Bool = true) -> AuthResult? {
    var result: AuthResult?

    if config.items["device_code"] != nil && checkAccessData("user_code") {
      let userCode = config.items["user_code"]!
      let deviceCode = config.items["device_code"]!

      result = AuthResult(userCode: userCode, deviceCode: deviceCode)
    } else {
      do {
        if let (response, _) = try ApiClient.await({
          self.authClient.getActivationCodes(includeClientSecret: includeClientSecret)
        }) {
          if let userCode = response.userCode, let deviceCode = response.deviceCode {
            self.config.items["user_code"] = userCode
            self.config.items["device_code"] = deviceCode
            self.config.items["activation_url"] = authClient.getActivationUrl()

            self.saveConfig()

            result = AuthResult(userCode: userCode, deviceCode: deviceCode)
          }
        }
      } catch {
        print(error)
      }
    }

    return result
  }

  func checkAuthorization() {
    var ok = false

    if checkAccessData("access_token") {
      ok = true
    } else if config.items["refresh_token"] != nil {
      ok = tryUpdateToken()
    }

    if !ok {
      //var ok = false

      if config.items["device_code"] != nil {
        let deviceCode = config.items["device_code"]

        do {
          if let deviceCode = deviceCode,
             let (response, _) = try ApiClient.await({ self.authClient.createToken(deviceCode: deviceCode) }) {

            ok = true

            self.config.items = response.asConfigurationItems()
            self.saveConfig()
          }
        } catch {
          print(error)
        }
      }

      //return ok
    }

    if !ok {
      authorizeCallback()
    }
  }

  func tryCreateToken(userCode: String, deviceCode: String) -> AuthProperties? {
    print("Register activation code on web site \(authClient.getActivationUrl()): \(userCode)")

    var result: AuthProperties?

    var done = false

    while !done {
      do {
        if let (response, _) = try ApiClient.await({ self.authClient.createToken(deviceCode: deviceCode) }) {
          done = response.accessToken != nil

          if done {
            result = response

            self.config.items = response.asConfigurationItems()
            saveConfig()
          }
        }
      } catch {
        print(error)
      }

      if !done {
        sleep(5)
      }
    }

    return result
  }

  func tryUpdateToken() -> Bool {
    var ok = false

    let refreshToken = config.items["refresh_token"]

    do {
      if let refreshToken = refreshToken,
         let (response, _) = try ApiClient.await({
           self.authClient.updateToken(refreshToken: refreshToken)
         }) {
        self.config.items = response.asConfigurationItems()
        self.saveConfig()

        ok = true
      }
    } catch {
      print(error)
    }

    return ok
  }

  func checkAccessData(_ key: String) -> Bool {
    return (config.items[key] != nil) && (config.items["expires"] != nil) &&
      config.items["expires"]! >= String(Int(Date().timeIntervalSince1970))
  }
}

extension EtvnetApiClient {
  func fullRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) -> FullValue<T>? {
    var result: FullValue<T>?

    checkAuthorization()

    if let accessToken = config.items["access_token"] {
      let queryItems = addAccessToken(params: params, accessToken: accessToken)

      var headers: [HttpHeader] = []
      headers.append(HttpHeader(field: "User-agent", value: EtvnetAPI.UserAgent))

      let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers)

      let semaphore = DispatchSemaphore.init(value: 0)

      let disposable = fetchRx(request, to: type).subscribe(onNext: { r in
        result = r

        let statusCode = r.response.statusCode

        if (statusCode == 401 || statusCode == 400) && !unauthorized {
          if self.tryUpdateToken() {
            result = self.fullRequest(path: path, to: type, method: method, params: params, unauthorized: true)
          }
        }

        semaphore.signal()
      },
        onError: { (error) -> Void in
          print("Error: \(error)")
          semaphore.signal()
        })

      _ = semaphore.wait(timeout: DispatchTime.distantFuture)

      disposable.dispose()
    }

    return result
  }
}
