import Foundation
import Files
import RxSwift

open class StringConfigFile: ConfigFile<String> {
  var fileName: String = ""

  let fileManager = FileManager.default

  let storage: DiskStorage!

  public init(_ fileName: String) {
    self.fileName = fileName

    let path = URL(fileURLWithPath: NSTemporaryDirectory())

    storage = DiskStorage(path: path)
  }

  public func exists() -> Bool {
    return fileManager.fileExists(atPath: fileName)
  }

//  public func read1() throws {
//    clear()
//
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    storage.read([String: Item].self, for: fileName) { result in
//      self.items = try! result.get()
//
//      semaphore.signal()
//    }
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//  }
//
//  public func write1() throws {
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    storage.write(items, for: fileName) { result in
//      semaphore.signal()
//    }
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//  }

  public func read() throws -> Observable<ConfigurationItems<String>> {
    clear()

    return storage.read([String: Item].self, for: fileName).map { items in
      self.items = items

      return items
    }
  }

  public func write() throws -> Observable<ConfigurationItems<String>> {
    return storage.write(items, for: fileName)
  }
}
