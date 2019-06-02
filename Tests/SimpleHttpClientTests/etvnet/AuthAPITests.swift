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
    if let result = subject.await({ self.subject.getActivationCodes() }) {
      XCTAssertNotNil(result)

      print("Activation url: \(self.subject.getActivationUrl())")
      print("Activation code: \(result.userCode)")
      print("Device code: \(result.deviceCode)")
    }
    else {
      XCTFail("Error during request")
    }
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
    let refreshToken = subject.config.items["refresh_token"]!

    if let result1 = subject.await({ self.subject.updateToken(refreshToken: refreshToken) }) {
      XCTAssertNotNil(result1.accessToken)

      print("Result: \(result1)")

      subject.config.items = result1.asConfigurationItems()

      if let _ = subject.await({ self.subject.config.write() }) {
        print("Saved config.")
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
