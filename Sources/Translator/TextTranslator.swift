public protocol TextTranslator {
	func translate(text: String, from: String, to: String) throws -> String
	func supports(from: String, to: String) -> Bool
}
