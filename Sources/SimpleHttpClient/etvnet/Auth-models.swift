import Foundation

public struct AuthResult {
  let userCode: String
  let deviceCode: String
}

public struct ActivationCodesProperties: Codable, CustomStringConvertible {
  public let deviceCode: String?
  public let userCode: String?

  enum CodingKeys: String, CodingKey {
    case deviceCode = "device_code"
    case userCode = "user_code"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    deviceCode = try container.decode(forKey: .deviceCode, default: nil)
    userCode = try container.decode(forKey: .userCode, default: nil)
  }

  public var description: String {
    return "ActivationCodesProperties(\(deviceCode ?? ""), \(userCode ?? ""))"
  }
}

public struct AuthProperties: Codable, CustomStringConvertible {
  public var accessToken: String?
  public var refreshToken: String?
  public var expiresIn: Int?

  private var expires: Int?

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    accessToken = try container.decode(forKey: .accessToken, default: nil)
    refreshToken = try container.decode(forKey: .refreshToken, default: nil)
    expiresIn = try container.decode(forKey: .expiresIn, default: nil)

    if let expiresIn = expiresIn {
      expires = Int(Date().timeIntervalSince1970) + expiresIn
    }
  }

  public func asConfigurationItems() -> ConfigurationItems<String> {
    var dict = ConfigurationItems<String>()

    if let accessToken = accessToken {
      dict["access_token"] = accessToken
    }

    if let refreshToken = refreshToken {
      dict["refresh_token"] = refreshToken
    }

    if let expires = expires{
      dict["expires"] = String(expires)
    }

    return dict
  }

  public var description: String {
    return "AuthProperties(\(accessToken ?? ""), \(refreshToken ?? ""), \(expiresIn ?? 0), \(expires ?? 0))"
  }
}
