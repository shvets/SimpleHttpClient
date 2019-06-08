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
    if let result = try subject.authService0.await({ self.subject.authService0.getActivationCodes() }) {
      XCTAssertNotNil(result)

      print("Activation url: \(self.subject.authService0.getActivationUrl())")
      print("Activation code: \(result.userCode!)")
      print("Device code: \(result.deviceCode!)")
    }
    else {
      XCTFail("Error during request")
    }
  }
  
  func testCreateToken() {
    if let result = subject.apiService.authorization() {
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
    let refreshToken = subject.apiService.config.items["refresh_token"]!

    if let result = try subject.authService0.await({ self.subject.authService0.updateToken(refreshToken: refreshToken) }) {
      XCTAssertNotNil(result.accessToken)

      print("Result: \(result)")

      subject.apiService.config.items = result.asConfigurationItems()

      if let _ = try subject.authService0.await({ self.subject.apiService.config.write() }) {
        print("Config saved.")
      }
      else {
        XCTFail()
      }
    }
    else {
      XCTFail("Error during request")
    }
  }
}
