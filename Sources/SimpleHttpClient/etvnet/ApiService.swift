import Foundation
import RxSwift

open class ApiService: ApiClient {
  public var config: ConfigFile<String>

  let authService: AuthService

  public var authorizeCallback: () -> Void = {}

  let apiUrl: String
  let userAgent: String
  
  init(config: ConfigFile<String>, apiUrl: String, userAgent: String, authUrl: String, clientId: String,
       clientSecret: String, grantType: String, scope: String) {
    self.config = config
    self.apiUrl = apiUrl
    self.userAgent = userAgent

    self.authService = AuthService(authUrl: authUrl, clientId: clientId, clientSecret: clientSecret,
               grantType: grantType, scope: scope)

    super.init(URL(string: authUrl)!)

    if (config.exists()) {
      self.loadConfig()
    }
  }

  public func authorize(authorizeCallback: @escaping () -> Void) {
    self.authorizeCallback = authorizeCallback
  }
  
  public func resetToken() {
    _ = config.remove("access_token")
    _ = config.remove("refresh_token")
    _ = config.remove("device_code")
    _ = config.remove("user_code")
    _ = config.remove("activation_url")

    saveConfig()
  }

  func loadConfig() {
    do {
      try authService.await {
        self.config.read()
      }
    }
    catch {
      print(error)
    }
  }

  func saveConfig() {
    do {
      try authService.await({ self.config.write() })
    }
    catch {
      print(error)
    }
  }
  
  public func authorization(includeClientSecret: Bool=true) -> AuthResult? {
    var result: AuthResult?

    if checkAccessData("device_code") && checkAccessData("user_code") {
      let userCode = config.items["user_code"]!
      let deviceCode = config.items["device_code"]!

      result = AuthResult(userCode: userCode, deviceCode: deviceCode)
    }
    else {
      do {
        if let response = try authService.await({ self.authService.getActivationCodes(includeClientSecret: includeClientSecret) }) {
          if let userCode = response.userCode, let deviceCode = response.deviceCode {
            self.config.items["user_code"] = userCode
            self.config.items["device_code"] = deviceCode
            self.config.items["activation_url"] = authService.getActivationUrl()

            self.saveConfig()

            result = AuthResult(userCode: userCode, deviceCode: deviceCode)
          }
        }
      }
      catch {
        print(error)
      }
    }

    return result
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
           let response = try authService.await({ self.authService.createToken(deviceCode: deviceCode) }) {

          self.config.items = response.asConfigurationItems()
          self.saveConfig()
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
      if let response = try authService.await({ self.authService.updateToken(refreshToken: refreshToken) }) {
        self.config.items = response.asConfigurationItems()
        self.saveConfig()

        ok = true
      }
    }
    catch {
      print(error)
    }

    return ok
  }

  func fullRequest<T: Decodable>(url: String, path: String, to type: T.Type, method: HttpMethod = .get,
                                 params: [URLQueryItem] = [], unauthorized: Bool=false) -> T? {
    var result: T?

    if !checkToken() {
      authorizeCallback()
    }

    if let accessToken = config.items["access_token"] {
      var queryItems: [URLQueryItem] = []

      for param in params {
        queryItems.append(param)
      }

      queryItems.append(URLQueryItem(name: "access_token", value: accessToken))

        var headers: [HttpHeader] = []
        headers.append(HttpHeader(field: "User-agent", value: userAgent))

        if let apiResponse = httpRequest(url: url, path: path, to: type, method: method, queryItems: queryItems,
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
    }

    return result
  }

  public func httpRequest<T: Decodable>(url: String, path: String, to type: T.Type, method: HttpMethod = .get,
                                        queryItems: [URLQueryItem] = [], headers: [HttpHeader] = []) -> T? {
    //var result: T?

    let client = ApiClient(URL(string: url)!)

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
