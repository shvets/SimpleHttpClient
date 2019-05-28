import Foundation
import RxSwift
import Files

public struct ConfigurationItems<T: Codable>: Codable {
  private var dict: Dictionary<String, T> = [:]

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

  public mutating func removeValue(forKey: String) {
    dict.removeValue(forKey: forKey)
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

  func read() -> Observable<ConfigurationItems<Item>>

  func write() -> Observable<ConfigurationItems<Item>>

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

  public init(_ fileName: String) {
    self.name = fileName

    let path = URL(fileURLWithPath: NSTemporaryDirectory())

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

  public func read() -> Observable<ConfigurationItems<T>> {
    clear()

    return storage.read(ConfigurationItems<T>.self, for: name).map { items in
      self.items = items

      return items
    }
  }

  public func write() -> Observable<ConfigurationItems<T>> {
    return storage.write(items, for: name)
  }

  public func exists() -> Bool {
    return fileManager.fileExists(atPath: name)
  }
}
