import Foundation

class CodableStorage: DiskStorage {
  init(path: URL) {
    super.init(path: path)
  }

  func read<T: Decodable>(for key: String, using decoder: AnyDecoder = JSONDecoder()) throws -> T {
    let data = try super.read(for: key)

    return try data.decoded(using: decoder)
  }

  func write<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder = JSONEncoder()) throws {
    let data = try value.encoded(using: encoder)

    try super.write(value: data, for: key)
  }
}