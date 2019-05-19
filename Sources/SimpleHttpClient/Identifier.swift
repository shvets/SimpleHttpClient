import Foundation

public protocol Identifiable {
  associatedtype RawIdentifier = String
  typealias ID = Identifier<Self>
  var id: ID { get }
}

public struct Identifier<T: Identifiable> {
  let rawValue: T.RawIdentifier

  public init(rawValue: T.RawIdentifier) {
    self.rawValue = rawValue
  }
}

// String literal support

extension Identifier: ExpressibleByUnicodeScalarLiteral where T.RawIdentifier: ExpressibleByUnicodeScalarLiteral {
  public init(unicodeScalarLiteral value: T.RawIdentifier.UnicodeScalarLiteralType) {
    rawValue = .init(unicodeScalarLiteral: value)
  }
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral
  where T.RawIdentifier: ExpressibleByExtendedGraphemeClusterLiteral {
  public init(extendedGraphemeClusterLiteral value: T.RawIdentifier.ExtendedGraphemeClusterLiteralType) {
    rawValue = .init(extendedGraphemeClusterLiteral: value)
  }
}

extension Identifier: ExpressibleByStringLiteral where T.RawIdentifier: ExpressibleByStringLiteral {
  public init(stringLiteral value: T.RawIdentifier.StringLiteralType) {
    rawValue = .init(stringLiteral: value)
  }
}

// Integer literal support

extension Identifier: ExpressibleByIntegerLiteral where T.RawIdentifier: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: T.RawIdentifier.IntegerLiteralType) {
    rawValue = .init(integerLiteral: value)
  }
}

// Compiler-generated protocol support

extension Identifier: Equatable where T.RawIdentifier: Equatable {}
extension Identifier: Hashable where T.RawIdentifier: Hashable {}

// Codable support

extension Identifier: Codable where T.RawIdentifier: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    rawValue = try container.decode(T.RawIdentifier.self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    try container.encode(rawValue)
  }
}

//extension Identifier: Codable {
//  public init(from decoder: Decoder) throws {
//    let container = try decoder.singleValueContainer()
//
//    self.rawValue = try container.decode(T.RawIdentifier.self)
//  }
//
//  public func encode(to encoder: Encoder) throws {
//    var container = encoder.singleValueContainer()
//
//    try container.encode(self.rawValue)
//  }
//}
