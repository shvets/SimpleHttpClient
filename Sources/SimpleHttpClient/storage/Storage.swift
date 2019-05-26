import Foundation

protocol ReadableStorage {
  func read(for key: String) throws -> Data

  func read(for key: String, handler: @escaping (Result<Data, Error>) -> Void)
}

protocol WritableStorage {
  func write(value: Data, for key: String) throws

  func write(value: Data, for key: String, handler: @escaping (Result<Data, Error>) -> Void)
}

typealias Storage = ReadableStorage & WritableStorage
