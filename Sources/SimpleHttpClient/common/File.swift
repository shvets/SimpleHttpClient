import Foundation
import Files

extension File {
  public static func exists(atPath path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }
}
