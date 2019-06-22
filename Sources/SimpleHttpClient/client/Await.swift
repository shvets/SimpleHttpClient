import Foundation
import RxSwift

class Await {
//  static func await<T>(_ handler: @escaping () -> Result<T, ApiError>) throws -> T? {
//    var result: T?
//    var error: Error?
//
//    let semaphore = DispatchSemaphore.init(value: 0)
//
//    switch handler() {
//      case .success(let response):
//        result = response
//        semaphore.signal()
//      case .failure(let e):
//        error = e
//        semaphore.signal()
//    }
//
//    _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//
//    if let error = error {
//      throw error
//    }
//
//    return result
//  }

  @discardableResult
  static func awaitRx<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let subscription = handler().subscribe(onNext: { response in
      result = response
      semaphore.signal()
    },
      onError: { (e) -> Void in
        error = e
        semaphore.signal()
      }
    )

    _ = semaphore.wait(timeout: DispatchTime.distantFuture)

    subscription.dispose()

    if let error = error {
      throw error
    }

    return result
  }
}