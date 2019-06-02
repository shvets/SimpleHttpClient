import XCTest

@testable import SimpleHttpClient

class AuthAPITests: XCTestCase {
  static func getProjectDirectory() -> String {
    return String(URL(fileURLWithPath: #file).pathComponents
      .prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst());
  }

  static let path = URL(fileURLWithPath: getProjectDirectory())

  static var config = ConfigFile<String>(path: path, fileName: "etvnet.config")
  
  var subject = EtvnetAPI(config: config)
  
  func testGetActivationCodes() throws {
    let result = subject.getActivationCodes()

    XCTAssertNotNil(result)

    if let result = result {
      print("Activation url: \(subject.getActivationUrl())")
      print("Activation code: \(result.userCode!)")
      print("Device code: \(result.deviceCode!)") 
    }
  }
  
  func testCreateToken() {
    let result = subject.authorization()

    if result != nil && result.userCode != "" {
      let response = subject.tryCreateToken(
          userCode: result.userCode,
          deviceCode: result.deviceCode
      )!

      XCTAssertNotNil(response.accessToken)
      XCTAssertNotNil(response.refreshToken)

      print("Result: \(result)")
    }
    else {
      XCTFail()
    }
  }
  
  func testUpdateToken() throws {
    let exp = expectation(description: "Tests update token")

    let refreshToken = subject.config.items["refresh_token"]!
    
    let result = subject.updateToken(refreshToken: refreshToken)

    if let result = result {
      XCTAssertNotNil(result.accessToken)

      print("Result: \(result)")

      subject.config.items = result.asConfigurationItems()

      subject.config.write().subscribe(onNext: { items in
        exp.fulfill()
      }, onError: { (error) -> Void in
        print(error)
        XCTFail()
      })

      waitForExpectations(timeout: 10)
    }
    else {
      XCTFail()
    }
  }
}
