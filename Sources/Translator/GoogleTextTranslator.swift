import Foundation

public struct GoogleTextTranslator: TextTranslator {
	private let apiKey: String
	
	public init(apiKey: String) {
		self.apiKey = apiKey
	}

	public func supports(from: String, to: String) -> Bool {
		// https://cloud.google.com/translate/docs/languages?hl=ja
		let supportedLanguages: [String] = [
			"af",
			"sq",
			"am",
			"ar",
			"hy",
			"az",
			"eu",
			"be",
			"bn",
			"bs",
			"bg",
			"ca",
			"ceb",
			"zh",
			"zh-CN",
			"zh-TW",
			"co",
			"hr",
			"cs",
			"da",
			"nl",
			"en",
			"eo",
			"et",
			"fi",
			"fr",
			"fy",
			"gl",
			"ka",
			"de",
			"el",
			"gu",
			"ht",
			"ha",
			"haw",
			"he",
			"iw",
			"hi",
			"hmn",
			"hu",
			"is",
			"ig",
			"id",
			"ga",
			"it",
			"ja",
			"jv",
			"kn",
			"kk",
			"km",
			"rw",
			"ko",
			"ku",
			"ky",
			"lo",
			"lv",
			"lt",
			"lb",
			"mk",
			"mg",
			"ms",
			"ml",
			"mt",
			"mi",
			"mr",
			"mn",
			"my",
			"ne",
			"no",
			"ny",
			"or",
			"ps",
			"fa",
			"pl",
			"pt",
			"pa",
			"ro",
			"ru",
			"sm",
			"gd",
			"sr",
			"st",
			"sn",
			"sd",
			"si",
			"sk",
			"sl",
			"so",
			"es",
			"su",
			"sw",
			"sv",
			"tl",
			"tg",
			"ta",
			"tt",
			"te",
			"th",
			"tr",
			"tk",
			"uk",
			"ur",
			"ug",
			"uz",
			"vi",
			"cy",
			"xh",
			"yi",
			"yo",
			"zu",
		]
		return supportedLanguages.contains(from) && supportedLanguages.contains(to)
	}
	
  public func translate(text: String, from: String, to: String, hash: String?) throws -> String {
    if from == to {
      return text
    }
    
		let url = URL(string: "https://translation.googleapis.com/language/translate/v2")!
		var components = URLComponents()
		components.queryItems = [
			URLQueryItem(name: "key", value: self.apiKey),
			URLQueryItem(name: "q", value: text),
			URLQueryItem(name: "source", value: from),
			URLQueryItem(name: "target", value: to),
			URLQueryItem(name: "format", value: "text"),
		]
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
		
		guard let (data, response) = HTTPRequest.fetch(request: request) else {
			throw TranslationError.invalidHTTPResponse
		}
		guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
			throw TranslationError.invalidHTTPResponse
		}
		
		if statusCode != 200 {
			throw TranslationError.badStatusCode(statusCode)
		}
		let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
		if let responseJSON = responseJSON as? [String: Any] {
			guard let data = responseJSON["data"] as? [String: Any] else {
				throw TranslationError.unsupportedResponse
			}
			guard let translations = data["translations"] as? [[String: String]] else {
				throw TranslationError.unsupportedResponse
			}
			if translations.count != 1 {
				throw TranslationError.unexpectedManyTranslations
			}
			guard let translatedText = translations[0]["translatedText"] else {
				throw TranslationError.unsupportedResponse
			}
			return translatedText
		} else {
			throw TranslationError.unsupportedResponse
		}
	}
}
