import Foundation
import Files

open class StringConfigFile: ConfigFile<String> {
  public typealias Item = String

  var fileName: String = ""

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let fileManager = FileManager.default

  public init(_ fileName: String) {
    self.fileName = fileName
  }

  public override func exists() -> Bool {
    return fileManager.fileExists(atPath: fileName)
  }

  public override func remove(_ key: String) -> Bool {
    return items.removeValue(forKey: key) != nil
  }

  public override func load() throws {
    clear()

    let data = try File(path: fileName).read()

    items = try decoder.decode([String: Item].self, from: data)
  }

  public override func save() throws {
    let data = try encoder.encode(items)

    try FileSystem().createFile(at: fileName, contents: data)
  }

}
