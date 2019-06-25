import Foundation
import RxSwift

enum StorageError: Error {
  case genericError(error: Error)
  case notFound
  case cantWrite(Error)
}

protocol ReadableStorage {
  func read<T: Decodable>(_  type: T.Type, for key: String,
                          handler: @escaping (Result<T, StorageError>) -> Void)

  //func readRx<T: Decodable>(_  type: T.Type, for key: String, using decoder: AnyDecoder) -> Observable<T>
}

protocol WritableStorage {
  func write<T: Encodable>(_ value: T, for key: String,
                           handler: @escaping (Result<T, StorageError>) -> Void)

  //func writeRx<T: Encodable>(_ value: T, for key: String, using encoder: AnyEncoder) -> Observable<T>
}

typealias Storage = ReadableStorage & WritableStorage
