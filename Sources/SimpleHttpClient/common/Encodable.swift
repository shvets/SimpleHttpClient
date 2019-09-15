import Foundation
import Codextended

extension Encodable {
  public func prettify() throws -> String {
    if let result = String(data: try encoded(), encoding: .utf8) {
      return result
    }
    else {
      return "<cannot encode>" 
    }
  }
}
