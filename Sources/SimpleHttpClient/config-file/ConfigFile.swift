import Foundation
import Files

open class ConfigFile<T: Codable> {
  public typealias Item = T

  private let fileManager = FileManager.default

  private var list: [String: Item] = [:]

  public var items: [String: Item] {
    get {
      return list
    }

    set {
      list = newValue
    }
  }

  private var fileName: String = ""

  private let storage: DiskStorage!

  public init(path: URL, fileName: String) {
    self.storage = DiskStorage(path: path)

    self.fileName = fileName
  }
}

extension ConfigFile: Configuration {
  public func exists() -> Bool {
    return fileManager.fileExists(atPath: "\(storage.getPath())/\(fileName)")
  }

  public func clear() {
    items.removeAll()
  }

  public func add(key: String, value: T) {
    items[key] = value
  }

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public func read(_ handler: @escaping (Result<[String: Item], StorageError>) -> Void) {
    clear()

    self.storage.read([String: Item].self, for: self.fileName, handler)
  }

  public func write(_ handler: @escaping (Result<[String: Item], StorageError>) -> Void) {
    self.storage.write(self.items, for: self.fileName, handler)
  }
}
