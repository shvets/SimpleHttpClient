typealias ConfigurationItems<T> = Dictionary<String, T>;

protocol Configuration {
  associatedtype Item

  var items: ConfigurationItems<Item> { get set }

  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool

  func clear()

//  func load() throws
//
//  func save() throws

//  func exists() -> Bool
}

open class ConfigFile<T> {
  typealias Item = T

  private var list: ConfigurationItems<Item> = [:]

  internal var items: ConfigurationItems<Item> {
    get {
      return list
    }
    set {
      list = newValue
    }
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

//  func load() throws {
//  }
//
//  func save() throws {
//  }

//  func exists() -> Bool {
//    fatalError("exists() has not been implemented")
//  }
}
