import Foundation
import Alamofire
import RxSwift

open class ApiService: AuthService {
  public var config: ConfigFile<String>

  public var authorizeCallback: () -> Void = {}

  let apiUrl: String
  let userAgent: String
  
  init(config: ConfigFile<String>, apiUrl: String, userAgent: String, authUrl: String, clientId: String,
       clientSecret: String, grantType: String, scope: String) {
    self.config = config
    
    self.apiUrl = apiUrl
    self.userAgent = userAgent
    
    super.init(authUrl: authUrl, clientId: clientId, clientSecret: clientSecret,
               grantType: grantType, scope: scope)

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
      try client.await({ self.config.read() })
    }
    catch {
      print(error)
    }
  }

  func saveConfig() {
    do {
      try client.await({ self.config.write() })
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
        if let response = try client.await({ self.getActivationCodes(includeClientSecret: includeClientSecret) }) {
          if let userCode = response.userCode, let deviceCode = response.deviceCode {
            self.config.items["user_code"] = userCode
            self.config.items["device_code"] = deviceCode
            self.config.items["activation_url"] = self.getActivationUrl()

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
           let response = try client.await({ self.createToken(deviceCode: deviceCode) }) {

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
      if let response = try client.await({ self.updateToken(refreshToken: refreshToken) }) {
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

  func fullRequest(path: String, method: HTTPMethod = .get, parameters: [String: String] = [:],
                   unauthorized: Bool=false) -> DataResponse<Data>? {
    var response: DataResponse<Data>?

    if !checkToken() {
      authorizeCallback()
    }

    if let accessToken = config.items["access_token"] {
      var accessPath: String

      if path.firstIndex(of: "?") != nil {
        accessPath = "\(path)&access_token=\(accessToken)"
      }
      else {
        accessPath = "\(path)?access_token=\(accessToken)"
      }

      if let accessPath = accessPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
        let headers = ["User-agent": userAgent]

        if let apiResponse = httpRequest(apiUrl + accessPath, headers: headers, parameters: parameters, method: method),
           let statusCode = apiResponse.response?.statusCode {
          if (statusCode == 401 || statusCode == 400) && !unauthorized {
            let refreshToken = config.items["refresh_token"]

            if let refreshToken = refreshToken, tryUpdateToken(refreshToken: refreshToken) {
              response = fullRequest(path: path, method: method, parameters: parameters, unauthorized: true)
            }
            else {
              print("error")
            }
          }
          else {
            response = apiResponse
          }
        }
      }
    }

    return response
  }

  func fullRequest0<T: Decodable>(url: String, path: String, to type: T.Type, method: HttpMethod = .get,
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

        if let apiResponse = httpRequest0(url: url, path: path, to: type, method: method, queryItems: queryItems,
          headers: headers) {

          result = apiResponse
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

  func fullRequestRx(path: String, method: HTTPMethod = .get, parameters: [String: String] = [:]) -> Observable<Data> {
    if !checkToken() {
      authorizeCallback()
    }
    
    if let accessToken = config.items["access_token"] {
      var accessPath: String
      
      if path.firstIndex(of: "?") != nil {
        accessPath = "\(path)&access_token=\(accessToken)"
      }
      else {
        accessPath = "\(path)?access_token=\(accessToken)"
      }
      
      if let accessPath = accessPath.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
        let headers = ["User-agent": userAgent]

        return httpRequestRx(apiUrl + accessPath, headers: headers, parameters: parameters, method: method)
      }
    }

    return Observable.just(Data())
  }

  public func httpRequestRx(_ url: String,
                            headers: HTTPHeaders = [:],
                            parameters: Parameters = [:],
                            method: HTTPMethod = .get,
                            unauthorized: Bool=false) -> Observable<Data> {
    return Observable.create { observer in
      if let sessionManager = self.sessionManager {
        let utilityQueue = DispatchQueue.global(qos: .utility)

        let request = sessionManager.request(url, method: method, parameters: parameters,
                        headers: headers).validate().responseData(queue: utilityQueue) { response in

        if let statusCode = response.response?.statusCode {
          if (statusCode == 401 || statusCode == 400) && !unauthorized {
            let refreshToken = self.config.items["refresh_token"]

            if let refreshToken = refreshToken, self.tryUpdateToken(refreshToken: refreshToken) {
              _ = self.httpRequestRx(url, headers: headers, parameters: parameters, method: method, unauthorized: true)
            }
            else {
              print("error")
            }
          }
          else {
            switch response.result {
              case .success(let value):
                observer.onNext(value)
                observer.onCompleted()

              case .failure(let error):
                observer.onError(error)
              }
            }
          }
        }

        return Disposables.create(with: request.cancel)
      }

      return Disposables.create()
    }
  }

}