import Foundation
import Files

extension File {
  public static func exists(atPath path: String) -> Bool {
    FileManager.default.fileExists(atPath: path)
  }
}
