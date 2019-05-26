protocol Configuration {
  associatedtype Item

  var items: [String: Item] { get set }

  func clear()

  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool

  func load() throws

  func save() throws

  func exists() -> Bool
}

extension Configuration {

}

open class ConfigFile<T>: Configuration {
  //typealias Item = T

  private var list: [String: T] = [:]

  public var items: [String: T] {
    get {
      return list
    }
    set {
      list = newValue
    }
  }

  public func clear() {
    items.removeAll()
  }

  public func add(key: String, value: T) {
    items[key] = value
  }

  func remove(_ key: String) -> Bool {
    fatalError("remove(_:) has not been implemented")
  }

  func load() throws {
  }

  func save() throws {
  }

  func exists() -> Bool {
    fatalError("exists() has not been implemented")
  }
}
