import Foundation

class DiskStorage {
  private let queue: DispatchQueue
  private let fileManager: FileManager
  private let path: URL

  init(path: URL, queue: DispatchQueue = .init(label: "DiskCache.Queue"),
       fileManager: FileManager = FileManager.default) {
    self.path = path
    self.queue = queue
    self.fileManager = fileManager
  }

  private func createFolders(in url: URL) throws {
    let folderUrl = url.deletingLastPathComponent()

    if !fileManager.fileExists(atPath: folderUrl.path) {
      try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
    }
  }
}

//func read<T: Decodable>(for key: String) throws -> T {
//  let data = try super.read(for: key)
//
//  return try decoder.decode(T.self, from: data)
//}

extension DiskStorage: ReadableStorage, WritableStorage {
  func read<T: Decodable>(for key: String, type: T.Type, using decoder: AnyDecoder = JSONDecoder(),
                          handler: @escaping StorageHandler<T>) {
    queue.async {
      let url = self.path.appendingPathComponent(key)

      if let data = self.fileManager.contents(atPath: url.path) {
        do {
          //let result = try data.decoded(using: decoder)

          let result = try decoder.decode(type, from: data)

          handler(.success(result))
        } catch {
          handler(.failure(.genericError(error: error)))
        }
      }
      else {
        handler(.failure(.notFound))
      }
    }
  }

  //
//func write<T: Encodable>(_ value: T, for key: String) throws {
//  let data = try encoder.encode(value)
//
//  try super.write(value: data, for: key)
//}

  func write<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder = JSONEncoder(),
                           handler: @escaping StorageHandler<T> = { _ in }) {
    queue.async {
      let url = self.path.appendingPathComponent(key)

      do {
        try self.createFolders(in: url)

        //let data = try value.encoded(using: encoder)

        let data = try encoder.encode(value)

        //try super.write(value: data, for: key)

        try data.write(to: url, options: .atomic)

        handler(.success(value))
      } catch {
        handler(.failure(.genericError(error: error)))
      }
    }
  }
}
