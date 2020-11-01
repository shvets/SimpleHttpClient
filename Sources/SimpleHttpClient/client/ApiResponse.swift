import Foundation

public struct ApiResponse {
  public let data: Data?
  public let response: HTTPURLResponse

//  public var status: HTTPStatus {
//    // A struct of similar construction to HTTPMethod
//    HTTPStatus(rawValue: response.statusCode)
//  }

  public var message: String {
    HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
  }

  public var headers: [AnyHashable: Any] { response.allHeaderFields }
}
