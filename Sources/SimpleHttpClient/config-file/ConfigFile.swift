import Foundation
import RxSwift
import Files

public struct ConfigurationItems<T: Codable>: Codable {
  private var dict: Dictionary<String, T> = [:]

  public init() {}

  public subscript(key: String) -> T? {
    get {
      return dict[key]
    }

    set(newValue) {
      dict[key] = newValue
    }
  }

  public mutating func removeAll() {
    dict.removeAll()
  }

  public mutating func removeValue(forKey: String) -> T? {
    return dict.removeValue(forKey: forKey)
  }

  public func asDictionary() -> Dictionary<String, T> {
    return dict
  }
}

protocol Configuration {
  associatedtype Item: Codable

  var items: ConfigurationItems<Item> { get set }

  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool

  func clear()

  func read() throws -> ConfigurationItems<Item>?

  func write() throws -> ConfigurationItems<Item>?

  func exists() -> Bool
}

open class ConfigFile<T: Codable> {
  typealias Item = T

  var name: String = ""

  let fileManager = FileManager.default

  private var list: ConfigurationItems<T> = ConfigurationItems()

  public var items: ConfigurationItems<T> {
    get {
      return list
    }
    set {
      list = newValue
    }
  }

  let storage: DiskStorage!

  public init(path: URL, fileName: String) {
    self.name = fileName

    storage = DiskStorage(path: path)
  }
}

extension ConfigFile: Configuration {
  public func add(key: String, value: T) {
    items[key] = value
  }

  public func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public func clear() {
    items.removeAll()
  }

  @discardableResult
  public func read() throws -> ConfigurationItems<T>? {
    clear()

    return try Await.await() { handler in
      self.storage.read(ConfigurationItems<T>.self, for: self.name, handler: handler)
    }
  }

  @discardableResult
  public func write() throws -> ConfigurationItems<T>? {
    return try Await.await() { handler in
      self.storage.write(self.items, for: self.name, handler: handler)
    }
  }

  public func exists() -> Bool {
    return fileManager.fileExists(atPath: "\(storage.getPath())/\(name)")
  }
}
