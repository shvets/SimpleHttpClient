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

    self.loadConfig()
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
    if (config.exists()) {
      //do {
      let semaphore = DispatchSemaphore.init(value: 0)

      config.read().subscribe(onNext: { items in
        semaphore.signal()
      },
        onError: { (error) -> Void in
          semaphore.signal()
          print("Error loading configuration: \(error)")
        })

      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//    }
//    catch let error {
//      print("Error loading configuration: \(error)")
//    }
    }
  }

//  func wrap() {
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    config.read().subscribe(onNext: { items in
//        semaphore.signal()
//      },
//      onError: { (error) -> Void in
//        semaphore.signal()
//        print("Error loading configuration: \(error)")
//      }
//    )
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//  }

  func saveConfig() {
    let semaphore = DispatchSemaphore.init(value: 0)

    config.write().subscribe(onNext: { items in
      semaphore.signal()
    },
    onError: { (error) -> Void in
      semaphore.signal()
      print("Error configuration configuration: \(error)")
    })

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }
  
  public func authorization(includeClientSecret: Bool=true) -> AuthResult {
    var result = AuthResult(userCode: "", deviceCode: "")

    if checkAccessData("device_code") && checkAccessData("user_code") {
      let userCode = config.items["user_code"]!
      let deviceCode = config.items["device_code"]!

      return AuthResult(userCode: userCode, deviceCode: deviceCode)
    }
    else {
      let semaphore = DispatchSemaphore.init(value: 0)

      getActivationCodes(includeClientSecret: includeClientSecret).subscribe(onNext: { r in
        if let userCode = r.userCode, let deviceCode = r.deviceCode {
          self.config.items["user_code"] = userCode
          self.config.items["device_code"] = deviceCode
          self.config.items["activation_url"] = self.getActivationUrl()

          self.saveConfig()

          result = AuthResult(userCode: userCode, deviceCode: deviceCode)
        }
        else {
          print("Error getting activation codes")
          result = AuthResult(userCode: "", deviceCode: "")
        }

        semaphore.signal()
      }, onError: { (error) -> Void in
        print("Error getting activation codes")

        result = AuthResult(userCode: "", deviceCode: "")

        semaphore.signal()
      })

      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
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
    var res = false

    if checkAccessData("access_token") {
      res = true
    }
    else if config.items["refresh_token"] != nil {
      let refreshToken = config.items["refresh_token"]
      
      if let refreshToken = refreshToken, tryUpdateToken(refreshToken: refreshToken) {
        res = true
      }
    }
    else if checkAccessData("device_code") {
      let deviceCode = config.items["device_code"]

      let semaphore = DispatchSemaphore.init(value: 0)

      createToken(deviceCode: deviceCode!).subscribe(onNext: { r in
        self.config.items = r.asConfigurationItems()
        self.saveConfig()

        semaphore.signal()
      }, onError: { (error) -> Void in
        semaphore.signal()
      })

      _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }

    return res
  }

  func tryUpdateToken(refreshToken: String) -> Bool {
    var ok = true

    let semaphore = DispatchSemaphore.init(value: 0)

    updateToken(refreshToken: refreshToken).subscribe(onNext: { response in
      self.config.items = response.asConfigurationItems()
      self.saveConfig()

      semaphore.signal()
    },
    onError: { (error) -> Void in
      semaphore.signal()
      print("Error loading configuration: \(error)")
      ok = false
    })

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

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

//  public override func httpRequestRx0(_ url: String,
//                            headers: HTTPHeaders = [:],
//                            parameters: Parameters = [:],
//                            method: HTTPMethod = .get) -> Observable<Data> {
//
//    if let sessionManager = self.sessionManager {
//      if let retrier = sessionManager.retrier, !(retrier is OAuth2Handler) {
//         sessionManager.retrier = OAuth2Handler(self)
//      }
//      else {
//         sessionManager.retrier = OAuth2Handler(self)
//      }
//    }
//
//    return super.httpRequestRx(url, headers: headers, parameters: parameters, method: method)
//  }

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
