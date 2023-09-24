import Foundation

public class SynchronizedOperation<T>: Operation {
  public var response: T? = nil

  var callback: () async throws -> T?

  public init(callback: @escaping () async throws -> T?) {
    self.callback = callback
  }

  public override func main() {
    let semaphore = DispatchSemaphore(value: 0)

    Task {
      self.response = try await self.callback()

      semaphore.signal()
    }

    semaphore.wait()
  }
}