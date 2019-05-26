import Foundation

class CodableStorage: DiskStorage {
  private let decoder = JSONDecoder()
  private let encoder = JSONEncoder()

  init(path: URL) {
    super.init(path: path)
  }

  func read<T: Decodable>(for key: String) throws -> T {
    let data = try super.read(for: key)

    return try decoder.decode(T.self, from: data)
  }

  func write<T: Encodable>(_ value: T, for key: String) throws {
    let data = try encoder.encode(value)

    try super.write(value: data, for: key)
  }
}