import Foundation

extension String {
  public func find(_ sub: String) -> String.Index? {
    return self.range(of: sub)?.lowerBound
  }
}