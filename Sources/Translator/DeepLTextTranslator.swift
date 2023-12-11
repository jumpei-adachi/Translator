import Foundation
import Dispatch

public struct DeepLTextTranslator: TextTranslator {
	private let apiKey: String
  
  public var preserveFormatting: Bool?
  
  public var context: String?
  
  public var formality: String?
  
	public init(apiKey: String) {
		self.apiKey = apiKey
	}

	public func supports(from: String, to: String) -> Bool {
		let supportedLanguages: [String] = [
			"bg",
			"cs",
			"da",
			"de",
			"el",
			"en",
			"es",
			"et",
			"fi",
			"fr",
			"hu",
			"id",
			"it",
			"ja",
			"ko",
			"lt",
			"lv",
			"nb",
			"nl",
			"pl",
			"pt",
			"ro",
			"ru",
			"sk",
			"sl",
			"sv",
			"tr",
			"uk",
			"zh",
		]
		return supportedLanguages.contains(from) && supportedLanguages.contains(to)
	}
	
	// DeepLでは一部の言語が国コードを必要とするため、必要な言語に国コードを追加する
	private func convertTargetLanguageForDeepL(target: String) -> String {
		switch target {
		case "en":
			return "en-US"
		case "pt":
			return "pt-PT"
		default:
			return target
		}
	}
	
	public func translate(text: String, from: String, to: String) throws -> String {
    if from == to {
      return text
    }
    
		let url = URL(string: "https://api-free.deepl.com/v2/translate")!
		var components = URLComponents()
    
    let targetLang = convertTargetLanguageForDeepL(target: to).uppercased()
    var queryItems: [URLQueryItem] = [
      URLQueryItem(name: "auth_key", value: self.apiKey),
      URLQueryItem(name: "text", value: text),
      URLQueryItem(name: "source_lang", value: from.uppercased()),
      URLQueryItem(name: "target_lang", value: targetLang),
    ]
    if let preserveFormatting {
      queryItems.append(URLQueryItem(name: "preserve_formatting", value: preserveFormatting.description))
    }
    if let context {
      queryItems.append(URLQueryItem(name: "context", value: context))
    }
    if ["DE", "FR", "IT", "ES", "NL", "PL", "PT-BR", "PT-PT", "JA", "RU"].contains(targetLang) {
      if let formality {
        queryItems.append(URLQueryItem(name: "formality", value: formality))
      }
    }
    
		components.queryItems = queryItems
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
			guard let translations = responseJSON["translations"] as? [[String: String]] else {
				throw TranslationError.unsupportedResponse
			}
			if translations.count != 1 {
				throw TranslationError.unexpectedManyTranslations
			}
			guard let translation = translations[0]["text"] else {
				throw TranslationError.unsupportedResponse
			}
			return translation
		} else {
			throw TranslationError.unsupportedResponse
		}
	}
}

struct HTTPRequest {
	static func fetch(request: URLRequest) -> (Data, URLResponse)? {
		var result: (Data, URLResponse)?
		let semaphore = DispatchSemaphore(value: 0)
		let task = URLSession.shared.dataTask(with: request) { data, response, error in
			defer {
				semaphore.signal()
			}
			if error != nil {
				return
			}
			guard let data = data else {
				return
			}
			guard let response = response else {
				return
			}
			result = (data, response)
		}
		task.resume()
		semaphore.wait()
		return result
	}
}
