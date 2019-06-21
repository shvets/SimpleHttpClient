import Foundation

public struct ApiResponse {
  public let statusCode: Int
  public let body: Data?
  public let response: HTTPURLResponse?
}
