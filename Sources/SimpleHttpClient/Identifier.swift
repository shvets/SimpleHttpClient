struct Identifier<T> {
  let value: String
}

extension Identifier: Codable {
  init(from decoder: Decoder) throws {
    self.value = try String(from: decoder)
  }

  func encode(to encoder: Encoder) throws {
    try value.encode(to: encoder)
  }
}
