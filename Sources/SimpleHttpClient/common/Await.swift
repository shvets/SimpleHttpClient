import Foundation

public class Await {
  @discardableResult
  public static func await<T, E: Error>(
    _ callback: @escaping (_ handler: @escaping (Result<T, E>) -> Void) -> Void) throws ->
    T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let handler: (Result<T, E>) -> Void = { (response) in
      switch response {
      case .success(let r):
        result = r
        semaphore.signal()

      case .failure(let e):
        error = e
        semaphore.signal()
      }
    }

    callback(handler)

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    if let error = error {
      throw error
    }

    return result
  }
}