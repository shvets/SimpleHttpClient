import Foundation
import RxSwift

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

  public func getPath() -> String {
    return String(path.pathComponents.joined(separator: "/").dropFirst())
  }
}

extension DiskStorage: ReadableStorage {
  func readAsync<T: Decodable>(_ type: T.Type, for key: String, using decoder: AnyDecoder = JSONDecoder(),
                          handler: @escaping StorageHandler<T>) {
    queue.async {
      let url = self.path.appendingPathComponent(key)

      if let data = self.fileManager.contents(atPath: url.path) {
        do {
          let value = try decoder.decode(type, from: data)

          handler(.success(value))
        } catch {
          handler(.failure(.genericError(error: error)))
        }
      }
      else {
        handler(.failure(.notFound))
      }
    }
  }

  func read<T: Decodable>(_ type: T.Type, for key: String, using decoder: AnyDecoder = JSONDecoder()) -> Observable<T> {
    return Observable.create { observer in
      let url = self.path.appendingPathComponent(key)

      if let data = self.fileManager.contents(atPath: url.path) {
        do {
          let value = try decoder.decode(type, from: data)

          observer.onNext(value)
          observer.onCompleted()
        } catch {
          observer.onError(StorageError.genericError(error: error))
        }
      }
      else {
        observer.onError(StorageError.notFound)
      }

      return Disposables.create()
    }
  }
}

extension DiskStorage: WritableStorage {
  func writeAsync<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder = JSONEncoder(),
                           handler: @escaping StorageHandler<T> = { _ in }) {
    queue.async {
      let url = self.path.appendingPathComponent(key)

      do {
        try self.createFolders(in: url)

        let data = try encoder.encode(value)

        try data.write(to: url, options: .atomic)

        handler(.success(value))
      } catch {
        handler(.failure(.genericError(error: error)))
      }
    }
  }

  func write<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder = JSONEncoder()) -> Observable<T> {
    return Observable.create { observer in

      let url = self.path.appendingPathComponent(key)

      do {
        try self.createFolders(in: url)

        let data = try encoder.encode(value)

        try data.write(to: url, options: .atomic)

        observer.onNext(value)
        observer.onCompleted()
      } catch {
        observer.onError(StorageError.genericError(error: error))
      }

      return Disposables.create()
    }
  }
}
