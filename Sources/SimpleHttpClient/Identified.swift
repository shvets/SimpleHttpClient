struct AnyCodingKey: CodingKey {
  var stringValue: String
  var intValue: Int?

  init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = "\(intValue)"
  }

  init?(stringValue: String) {
    self.intValue = nil
    self.stringValue = stringValue
  }
}

struct Identified<T> {
  let id: Identifier<T>

  let value: T
}

extension Identified: Codable where T: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: AnyCodingKey.self)

    self.id = try container.decode(Identifier<T>.self, forKey: AnyCodingKey(stringValue: "id")!)
    self.value = try T.init(from: decoder)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: AnyCodingKey.self)

    try container.encode(id, forKey: AnyCodingKey(stringValue: "id")!)
    try value.encode(to: encoder)
  }
}
