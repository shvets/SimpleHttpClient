import Foundation
import RxSwift

open class EtvnetApiClient: ApiClient {
  public let UserAgent = "Etvnet User Agent"

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

  public var configFile: ConfigFile<String>!

//  public var configFile: ConfigFile<String> {
//    get {
//      return self
//    }
//    set {
//      self = newValue
//    }
//  }

  let authClient: AuthApiClient!

  public var authorizeCallback: () -> Void = {}

  init(_ url: String, authUrl: String) {
    authClient = AuthApiClient(authUrl: authUrl, clientId: ClientId, clientSecret: ClientSecret,
      grantType: GrantType, scope: Scope)

    super.init(URL(string: url)!)
  }
}

extension EtvnetApiClient {
  func setConfigFile(_ configFile: ConfigFile<String>) {
    self.configFile = configFile
  }

  func loadConfig() {
    if (configFile.exists()) {
      do {
        try await {
          self.configFile.read()
        }
      } catch {
        print(error)
      }
    }
  }

  func saveConfig() {
    do {
      try await {
        self.configFile.write()
      }
    } catch {
      print(error)
    }
  }
}

extension EtvnetApiClient {
  public func resetToken() {
    _ = configFile.remove("access_token")
    _ = configFile.remove("refresh_token")
    _ = configFile.remove("device_code")
    _ = configFile.remove("user_code")
    _ = configFile.remove("activation_url")

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

    if configFile.items["device_code"] != nil && checkAccessData("user_code") {
      let userCode = configFile.items["user_code"]!
      let deviceCode = configFile.items["device_code"]!

      result = AuthResult(userCode: userCode, deviceCode: deviceCode)
    } else {
      do {
        let fullResponse = try await {
          self.authClient.getActivationCodes(includeClientSecret: includeClientSecret)
        }

        if let fullResponse = fullResponse {
          if let userCode = fullResponse.value.userCode,
             let deviceCode = fullResponse.value.deviceCode {
            self.configFile.items["user_code"] = userCode
            self.configFile.items["device_code"] = deviceCode
            self.configFile.items["activation_url"] = authClient.getActivationUrl()

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
    } else if configFile.items["refresh_token"] != nil {
      ok = tryUpdateToken()
    }

    if !ok {
      //var ok = false

      if configFile.items["device_code"] != nil {
        let deviceCode = configFile.items["device_code"]

        do {
          if let deviceCode = deviceCode {
            let fullResponse = try await {
              self.authClient.createToken(deviceCode: deviceCode)
            }

            if let fullResponse = fullResponse {
              ok = true

              self.configFile.items = fullResponse.value.asConfigurationItems()
              self.saveConfig()
            }
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
        let fullResponse = try await {
          self.authClient.createToken(deviceCode: deviceCode)
        }

        if let fullResponse = fullResponse {
          done = fullResponse.value.accessToken != nil

          if done {
            result = fullResponse.value

            self.configFile.items = fullResponse.value.asConfigurationItems()
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

    let refreshToken = configFile.items["refresh_token"]

    do {
      if let refreshToken = refreshToken {
        let fullResponse = try await {
          self.authClient.updateToken(refreshToken: refreshToken)
        }

        if let fullResponse = fullResponse {
          self.configFile.items = fullResponse.value.asConfigurationItems()
          self.saveConfig()

          ok = true
        }
      }
    } catch {
      print(error)
    }

    return ok
  }

  func checkAccessData(_ key: String) -> Bool {
    return (configFile.items[key] != nil) && (configFile.items["expires"] != nil) &&
      configFile.items["expires"]! >= String(Int(Date().timeIntervalSince1970))
  }
}

extension EtvnetApiClient {
  func fullRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) -> FullValue<T>? {
    var result: FullValue<T>?

    checkAuthorization()

    if let accessToken = configFile.items["access_token"] {
      let queryItems = addAccessToken(params: params, accessToken: accessToken)

      var headers: [HttpHeader] = []
      headers.append(HttpHeader(field: "User-agent", value: UserAgent))

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
