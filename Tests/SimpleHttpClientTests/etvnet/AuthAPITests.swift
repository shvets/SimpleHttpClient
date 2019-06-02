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
    let exp = expectation(description: "Tests Activation Codes")

    _ = subject.getActivationCodes().subscribe(onNext: { response in
      XCTAssertNotNil(response)

      print("Activation url: \(self.subject.getActivationUrl())")
      print("Activation code: \(response.userCode!)")
      print("Device code: \(response.deviceCode!)")

      exp.fulfill()
    }, onError: { (error) -> Void in
      print(error)
      XCTFail("Error during request: \(error)")

      exp.fulfill()
    })

    waitForExpectations(timeout: 10)
  }
  
  func testCreateToken() {
    let result = subject.authorization()

    if result.userCode != "" {
      if let response = subject.tryCreateToken(userCode: result.userCode, deviceCode: result.deviceCode) {
        XCTAssertNotNil(response.accessToken)
        XCTAssertNotNil(response.refreshToken)

        print("Result: \(result)") 
      }
      else {
        XCTFail()
      }
    }
    else {
      XCTFail()
    }
  }
  
  func testUpdateToken() throws {
    let exp = expectation(description: "Tests update token")

    let refreshToken = subject.config.items["refresh_token"]!

    var result1: AuthProperties?

    _ = subject.updateToken(refreshToken: refreshToken).subscribe(onNext: { result in
      result1 = result

      XCTAssertNotNil(result.accessToken)

      print("Result: \(result)")

      exp.fulfill()
    }, onError: { (error) -> Void in
      exp.fulfill()
    })

    waitForExpectations(timeout: 10)

    let exp2 = expectation(description: "Tests update token")

    if let result = result1 {
      subject.config.items = result.asConfigurationItems()

      _ = subject.config.write().subscribe(onNext: { items in
        exp2.fulfill()
      }, onError: { (error) -> Void in
        exp2.fulfill()
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
