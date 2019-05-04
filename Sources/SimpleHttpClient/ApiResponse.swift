import Foundation

struct ApiResponse<T> {
  let statusCode: Int
  let body: T
}
