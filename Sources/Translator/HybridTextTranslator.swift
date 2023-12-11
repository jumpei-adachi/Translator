public struct HybridTextTranslator: TextTranslator {
	private let translators: [TextTranslator]
	
	public init(translators: [TextTranslator]) {
		self.translators = translators
	}
	
	public func supports(from: String, to: String) -> Bool {
		translators.contains { translator in
			translator.supports(from: from, to: to)
		}
	}
	
  public func translate(text: String, from: String, to: String, hash: String?) throws -> String {
		for translator in translators {
			if translator.supports(from: from, to: to) {
        let target = try translator.translate(text: text, from: from, to: to, hash: hash)
				return target
			}
		}
		throw TranslationError.unsupportedLanguagePair
	}
}
