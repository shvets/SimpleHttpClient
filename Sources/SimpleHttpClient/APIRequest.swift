import Foundation

class APIRequest {
  let method: HTTPMethod2
    let path: String
    var queryItems: [URLQueryItem]?
    var headers: [HTTPHeader2]?
    var body: Data?

    init(method: HTTPMethod2, path: String) {
        self.method = method
        self.path = path
    }

    init<Body: Encodable>(method: HTTPMethod2, path: String, body: Body) throws {
        self.method = method
        self.path = path
        self.body = try JSONEncoder().encode(body)
    }
}
