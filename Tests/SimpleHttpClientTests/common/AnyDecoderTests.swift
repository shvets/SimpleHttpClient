import XCTest

@testable import SimpleHttpClient

struct Comment: Codable {
  let text: String
}

struct Video {
  let url: URL
  let containsAds: Bool
  var comments: [Comment]
}

extension Video: Codable, Equatable {
    static func == (lhs: Video, rhs: Video) -> Bool {
      return lhs.url == rhs.url
    }

  enum CodingKey: String, Swift.CodingKey {
    case url
    case containsAds = "contains_ads"
    case comments
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)

    url = try container.decode(forKey: .url)
    containsAds = try container.decode(forKey: .containsAds, default: false)
    comments = try container.decode(forKey: .comments, default: [] as [Comment])
  }
}

final class AnyDecoderTests: XCTestCase {
  struct User: Codable, Equatable {
    let firstName: String
    let lastName: String
  }

  func testDecoded() throws {
    let user = User(firstName: "Harry", lastName: "Potter")
    let data = try user.encoded()

    let result = try data.decoded() as User

    print(try data.decoded() as User)

    XCTAssertEqual(result, user)
  }

  func testDecodedWithContainer() throws {
    let comment = Comment(text: "I think...")
    let video = Video(url: URL(string: "http://localhost")!, containsAds: false, comments: [comment])
    let data = try video.encoded()

    let result = try data.decoded() as Video

    print(try data.decoded() as Video)

    XCTAssertEqual(result, video)
  }
}
