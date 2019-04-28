import Foundation

struct APIResponse<Body> {
  let statusCode: Int
  let body: Body
}

extension APIResponse where Body == Data? {
  func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIResponse<BodyType> {
    guard let data = body else {
      throw APIError.decodingFailure
    }

    let decodedJSON = try JSONDecoder().decode(BodyType.self, from: data)

    return APIResponse<BodyType>(statusCode: self.statusCode, body: decodedJSON)
  }
}
