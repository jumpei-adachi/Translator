/// 簡体字へ翻訳可能なTextTranslatorを、簡体字と繁体字の両方へ翻訳可能なTextTranslatorに拡張するデコレーター
public struct ChineseTextTranslator: TextTranslator {
	private let translator: TextTranslator
	
	public init(translator: TextTranslator) {
		self.translator = translator
	}

	public func supports(from: String, to: String) -> Bool {
		translator.supports(from: from, to: "zh") && (["zh-Hans", "zh-Hant", "zh-HK"].contains(to))
	}
	
  public func translate(text: String, from: String, to: String, hash: String?) throws -> String {
    let translated = try translator.translate(text: text, from: from, to: "zh", hash: hash)
		switch to {
		case "zh-Hans":
			return translated
		case "zh-Hant", "zh-HK":
			return SimplifiedTraditionalDictionary.convert(translated)
		default:
			fatalError("Impossible execution flow occurred")
		}
	}
}
