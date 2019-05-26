// https://www.swiftbysundell.com/posts/type-inference-powered-serialization-in-swift

import Foundation

protocol AnyDecoder {
  func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}

extension JSONDecoder: AnyDecoder {}

extension Data {
  func decoded<T: Decodable>(using decoder: AnyDecoder = JSONDecoder()) throws -> T {
    return try decoder.decode(T.self, from: self)
  }
}

extension KeyedDecodingContainerProtocol {
  func decode<T: Decodable>(forKey key: Key) throws -> T {
    return try decode(T.self, forKey: key)
  }

  func decode<T: Decodable>(forKey key: Key, default defaultExpression: @autoclosure () -> T) throws -> T {
    return try decodeIfPresent(T.self, forKey: key) ?? defaultExpression()
  }
}
