import Foundation
import RxSwift

public typealias ResultHandler<T> = (Result<T, ApiError>) -> Void

public class Await {
  public static func await<T>(_ callback: @escaping (_ handler: @escaping ResultHandler<T>) -> Void) throws ->
    T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let handler: ResultHandler<T> = { (response) in
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

  @discardableResult
  public static func awaitRx<T>(_ handler: @escaping () -> Observable<T>) throws -> T? {
    var result: T?
    var error: Error?

    let semaphore = DispatchSemaphore.init(value: 0)

    let subscription = handler().subscribe(
      onNext: { response in
        result = response
        semaphore.signal()
      },
      onError: { e in
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