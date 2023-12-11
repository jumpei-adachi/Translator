public protocol TextTranslator {
  func translate(text: String, from: String, to: String, hash: String?) throws -> String
	func supports(from: String, to: String) -> Bool
}

public extension TextTranslator {
  func translate(text: String, from: String, to: String) throws -> String {
    return try translate(text: text, from: from, to: to, hash: nil)
  }
}
