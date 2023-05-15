import Foundation
import SQLite

public struct CachedTextTranslator: TextTranslator {
	private let translator: TextTranslator
	private let cacheURL: URL
	
	public init(translator: TextTranslator, cacheURL: URL) {
		self.translator = translator
		self.cacheURL = cacheURL
	}
	
	public func supports(from: String, to: String) -> Bool {
		translator.supports(from: from, to: to)
	}
	
	private func createDatabaseIfNotExists() throws {
		if !FileManager.default.fileExists(atPath: cacheURL.path) {
			let db = try Connection(cacheURL.path)
			try db.run(
				"""
				CREATE TABLE cache(
					id INTEGER PRIMARY KEY AUTOINCREMENT,
					sourceLanguage TEXT NOT NULL,
					targetLanguage TEXT NOT NULL,
					sourceText TEXT NOT NULL,
					targetText TEXT NOT NULL
				)
				"""
			)
		}
	}
	
	private func translateUsingCache(text: String, sourceLanguage: String, targetLanguage: String) throws -> String? {
		try createDatabaseIfNotExists()
		let db = try Connection(cacheURL.path)
		if let result = (try db.prepare(
			"SELECT targetText FROM cache WHERE sourceLanguage=? AND targetLanguage=? AND sourceText=?",
			[sourceLanguage, targetLanguage, text]
		).scalar()) {
			return result as? String
		} else {
			return nil
		}
	}
	
	private func insertCache(sourceText: String, sourceLanguage: String, targetText: String, targetLanguage: String) throws {
		try createDatabaseIfNotExists()
		let db = try Connection(cacheURL.path)
		try db.run("INSERT INTO cache (sourceLanguage, targetLanguage, sourceText, targetText) VALUES (?, ?, ?, ?)", [sourceLanguage, targetLanguage, sourceText, targetText])
	}
	
	public func translate(text: String, from: String, to: String) throws -> String {
		if let result = try translateUsingCache(text: text, sourceLanguage: from, targetLanguage: to) {
			return result
		}
		let targetText = try translator.translate(text: text, from: from, to: to)
		try insertCache(sourceText: text, sourceLanguage: from, targetText: targetText, targetLanguage: to)
		return targetText
	}
}
