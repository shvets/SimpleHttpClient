import Foundation

enum StorageError: Error {
  case genericError(error: Error)
  case notFound
  case cantWrite(Error)
}

typealias StorageHandler<T> = (Result<T, StorageError>) -> Void

protocol ReadableStorage {
  func read<T: Decodable>(_  type: T.Type, for key: String, using decoder: AnyDecoder,
                          handler: @escaping StorageHandler<T>)
}

protocol WritableStorage {
  func write<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder,
                           handler: @escaping StorageHandler<T>)
}

typealias Storage = ReadableStorage & WritableStorage
