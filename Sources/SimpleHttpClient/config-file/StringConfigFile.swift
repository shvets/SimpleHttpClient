import Foundation
import Files
import RxSwift

open class StringConfigFile: ConfigFile<String> {
  var fileName: String = ""

//  let encoder = JSONEncoder()
//  let decoder = JSONDecoder()

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

  public func read() throws {
    clear()

//    let data = try File(path: fileName).read()
//
//    items = try decoder.decode([String: Item].self, from: data)

    let semaphore = DispatchSemaphore.init(value: 0)

    storage.read([String: Item].self, for: fileName) { result in
      print(result)
      self.items = try! result.get()

      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }

  public func write() throws {
    //let data = try encoder.encode(items)

    // try FileSystem().createFile(at: fileName, contents: data)

    let semaphore = DispatchSemaphore.init(value: 0)

    storage.write(items, for: fileName) { result in
      print(result)

      semaphore.signal()
    }

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
  }
}
