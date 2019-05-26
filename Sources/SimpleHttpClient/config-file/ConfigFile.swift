protocol ConfigFile {
  associatedtype Item

  var items: [String: Item] { get set }

  func clear()

  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool

  func load() throws

  func save() throws

  func exists() -> Bool
}
