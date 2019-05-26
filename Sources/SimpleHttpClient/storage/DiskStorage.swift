import Foundation

enum StorageError: Error {
  case notFound
  case cantWrite(Error)
}

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
}

extension DiskStorage: WritableStorage {
  func write(value: Data, for key: String) throws {
    let url = path.appendingPathComponent(key)

    do {
      try self.createFolders(in: url)

      try value.write(to: url, options: .atomic)
    } catch {
      throw StorageError.cantWrite(error)
    }
  }

  func write(value: Data, for key: String, handler: @escaping (Result<Data, Error>) -> Void) {
    queue.async {
      do {
        try self.write(value: value, for: key)

        handler(.success(value))
      } catch {
        handler(.failure(error))
      }
    }
  }
}

extension DiskStorage {
  private func createFolders(in url: URL) throws {
    let folderUrl = url.deletingLastPathComponent()

    if !fileManager.fileExists(atPath: folderUrl.path) {
      try fileManager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
    }
  }
}

extension DiskStorage: ReadableStorage {
  func read(for key: String) throws -> Data {
    let url = path.appendingPathComponent(key)

    guard let data = fileManager.contents(atPath: url.path) else {
      throw StorageError.notFound
    }

    return data
  }

  func read(for key: String, handler: @escaping (Result<Data, Error>) -> Void) {
    queue.async {
      handler(Result { try self.read(for: key) })
    }
  }
}
