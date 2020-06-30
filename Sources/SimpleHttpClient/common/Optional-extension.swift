extension Optional {
  public func orThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
    guard let value = self else {
      throw errorExpression()
    }

    return value
  }
}

extension Optional where Wrapped: Collection {
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
}

extension Optional {
  public func matching(_ predicate: (Wrapped) -> Bool) -> Wrapped? {
    guard let value = self else {
      return nil
    }

    guard predicate(value) else {
      return nil
    }

    return value
  }
}
