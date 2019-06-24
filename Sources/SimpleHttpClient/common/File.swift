import Foundation
import Files

extension File {
  public class func exists(atPath path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
  }
}
