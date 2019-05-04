import Foundation

struct APIResponse<T> {
  let statusCode: Int
  let body: T
}
