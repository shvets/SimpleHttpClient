/**
 *  Identity
 *  Copyright (c) John Sundell 2019
 *  Licensed under the MIT license (see LICENSE file)
 */

import XCTest
//import Identity

@testable import SimpleHttpClient

final class IdentityTests: XCTestCase {
  func testStringBasedIdentifier() {
    struct Model: Identifiable {
      let id: ID
    }

    let model = Model(id: "Hello, world!")
    XCTAssertEqual(model.id, "Hello, world!")
  }

  func testIntBasedIdentifier() {
    struct Model: Identifiable {
      typealias RawIdentifier = Int
      let id: ID
    }

    let model = Model(id: 7)
    XCTAssertEqual(model.id, 7)
  }

  func testCodableIdentifier() throws {
    struct Model: Identifiable, Codable {
      typealias RawIdentifier = UUID
      let id: ID
    }

    let model = Model(id: Identifier(rawValue: UUID()))
    let data = try JSONEncoder().encode(model)
    let decoded = try JSONDecoder().decode(Model.self, from: data)
    XCTAssertEqual(model.id, decoded.id)
  }

  func testIdentifierEncodedAsSingleValue() throws {
    struct Model: Identifiable, Codable {
      let id: ID
    }

    let model = Model(id: "I'm an ID")
    let data = try JSONEncoder().encode(model)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    XCTAssertEqual(json?["id"] as? String, "I'm an ID")
  }
}
