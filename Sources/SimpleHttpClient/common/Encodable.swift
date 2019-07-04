import Foundation
import Codextended

extension Encodable {
  public func prettify() throws -> String {
    return String(data: try encoded(), encoding: .utf8)!
  }
}
