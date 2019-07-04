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

  @discardableResult
  public func read() throws -> [String: Item]? {
    clear()

    let items = try Await.await() { handler in
      self.storage.read([String: Item].self, for: self.fileName, handler)
    }

    if let items = items {
      self.items = items
    }

    return self.items
  }

  @discardableResult
  public func write() throws -> [String: Item]? {
    return try Await.await() { handler in
      self.storage.write(self.items, for: self.fileName, handler)
    }
  }
}
