public enum TranslationError: Error {
	case badStatusCode(Int)
	case invalidHTTPResponse
	case unsupportedResponse
	case unexpectedManyTranslations
	case unsupportedLanguagePair
}
