import Foundation
import RxSwift

open class EtvnetApiClient: ApiClient {
  public let UserAgent = "Etvnet User Agent"

  public var configFile: ConfigFile<String>!

  let authClient: AuthApiClient!

  public var authorizeCallback: () -> Void = {}

  init(_ url: String, authUrl: String) {
    authClient = AuthApiClient(URL(string: authUrl)!)

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
    var newParams: [URLQueryItem] = []

    for param in params {
      newParams.append(param)
    }

    newParams.append(URLQueryItem(name: "access_token", value: accessToken))

    return newParams
  }

  public func authorization(includeClientSecret: Bool = true) throws -> AuthResult? {
    var result: AuthResult?

    if configFile.items["device_code"] != nil && checkAccessData("user_code") {
      let userCode = configFile.items["user_code"]!
      let deviceCode = configFile.items["device_code"]!

      result = AuthResult(userCode: userCode, deviceCode: deviceCode)
    } else {
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
    }

    return result
  }

  func checkAuthorization() -> Bool {
    var ok = false

    if checkAccessData("access_token") {
      ok = true
    } else if configFile.items["refresh_token"] != nil {
      do {
        let refreshToken = configFile.items["refresh_token"]

        if let refreshToken = refreshToken {
          if let result = try updateToken(refreshToken) {
            self.configFile.items = result.value.asConfigurationItems()
            self.saveConfig()
          }
        }
      } catch {
        print(error)
      }
    }

    if !ok {
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
    }

    return ok
  }

  func createToken(userCode: String, deviceCode: String) -> AuthProperties? {
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

  func updateToken(_ refreshToken: String) throws -> FullValue<AuthProperties>? {
    return try await {
      self.authClient.updateToken(refreshToken: refreshToken)
    }
  }

  func checkAccessData(_ key: String) -> Bool {
    return (configFile.items[key] != nil) && (configFile.items["expires"] != nil) &&
      configFile.items["expires"]! >= String(Int(Date().timeIntervalSince1970))
  }
}

extension EtvnetApiClient {
  func fullRequest<T: Decodable>(path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) throws -> FullValue<T>? {
    var result: FullValue<T>?

    if !checkAuthorization() {
      authorizeCallback()
    }

    if let accessToken = configFile.items["access_token"] {
      let queryItems = addAccessToken(params: params, accessToken: accessToken)

      var headers: [HttpHeader] = []
      headers.append(HttpHeader(field: "User-agent", value: UserAgent))

      let request = ApiRequest(path: path, queryItems: queryItems, method: method, headers: headers)

      result = try await {
        self.fetchRx(request, to: type)
      }

//      let semaphore = DispatchSemaphore.init(value: 0)
//
//      let disposable = fetchRx(request, to: type).subscribe(onNext: { r in
//        result = r

      if let r = result {
        let statusCode = r.response.statusCode

        if (statusCode == 401 || statusCode == 400) && !unauthorized {
          do {
            let refreshToken = self.configFile.items["refresh_token"]

            if let refreshToken = refreshToken {
              if let updateResult = try self.updateToken(refreshToken) {
                self.configFile.items = updateResult.value.asConfigurationItems()
                self.saveConfig()

                result = try self.fullRequest(path: path, to: type, method: method, params: params, unauthorized: true)
              }
            }
          } catch {
            print(error)
          }
        }
      }

//        semaphore.signal()
//      },
//        onError: { (error) -> Void in
//          print("Error: \(error)")
//          semaphore.signal()
//        })

//      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//      disposable.dispose()
    }

    return result
  }
}
