struct Identifier<T> {
  let value: String
}

extension Identifier: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    self.value = try container.decode(String.self)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    try container.encode(self.value)
  }
}

extension Identifier: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.value = value
  }
}

extension Identifier: CustomStringConvertible {
  var description: String {
    return value
  }
}

