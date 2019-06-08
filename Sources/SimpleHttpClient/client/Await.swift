import Foundation
import RxSwift

class Await {
  @discardableResult
  static func await<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let disposable = handler().subscribe(onNext: { response in
      result = response
      semaphore.signal()
    },
      onError: { (e) -> Void in
        error = e
        semaphore.signal()
      }
    )

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    disposable.dispose()

    if let error = error {
      throw error
    }

    return result
  }

  static func await0<T: Decodable>(_ handler: @escaping () -> Result<T, ApiError>) -> Result<T, ApiError> {
    let semaphore = DispatchSemaphore.init(value: 0)

    let result: Result<T, ApiError> = handler()

    semaphore.signal()

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    return result
  }
}