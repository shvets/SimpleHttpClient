import Foundation

protocol AnyEncoder {
  func encode<T: Encodable>(_ value: T) throws -> Data
}

extension JSONEncoder: AnyEncoder {}

extension Encodable {
  func encoded(using encoder: AnyEncoder = JSONEncoder()) throws -> Data {
    if let encoder = encoder as? JSONEncoder {
      encoder.outputFormatting = .prettyPrinted
    }

    return try encoder.encode(self)
  }

  func prettify() throws -> String {
    return String(data: try encoded(), encoding: .utf8)!
  }
}
