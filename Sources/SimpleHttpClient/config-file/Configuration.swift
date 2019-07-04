import Foundation

protocol Configuration {
  associatedtype Item: Codable

  var items: [String: Item] { get set }

  func exists() -> Bool
  
  func clear()
  
  func add(key: String, value: Item)

  func remove(_ key: String) -> Bool
  
  func read(_ handler: @escaping (Result<[String: Item], StorageError>) -> Void)

  func write(_ handler: @escaping (Result<[String: Item], StorageError>) -> Void)
}
