import Foundation

enum StorageError: Error {
  case notFound
  case cantWrite(Error)
}
