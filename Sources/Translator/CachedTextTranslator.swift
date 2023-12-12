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
  
  public func translate(text: String, from: String, to: String, hash: String?) throws -> String {
    if from == to {
      return text
    }
    if let result = try translateUsingCache(text: text, hash: hash, sourceLanguage: from, targetLanguage: to) {
      return result
    }
    let targetText = try translator.translate(text: text, from: from, to: to, hash: hash)
    try insertCache(hash: hash, sourceText: text, sourceLanguage: from, targetText: targetText, targetLanguage: to)
    return targetText
  }
	
	private func createDatabaseIfNotExists() throws {
		if !FileManager.default.fileExists(atPath: cacheURL.path) {
			let db = try Connection(cacheURL.path)
			try db.run(
"""
CREATE TABLE cache(
id INTEGER PRIMARY KEY AUTOINCREMENT,
hash TEXT,
sourceLanguage TEXT NOT NULL,
targetLanguage TEXT NOT NULL,
sourceText TEXT NOT NULL,
targetText TEXT NOT NULL
)
"""
			)
		}
	}
	
  private func translateUsingCache(text: String, hash: String?, sourceLanguage: String, targetLanguage: String) throws -> String? {
		try createDatabaseIfNotExists()
		let db = try Connection(cacheURL.path)
    let prepare = if let hash {
      try db.prepare(
        "SELECT targetText FROM cache WHERE sourceLanguage=? AND targetLanguage=? AND sourceText=? AND hash=?",
        [sourceLanguage, targetLanguage, text, hash]
      )
    } else {
      try db.prepare(
        "SELECT targetText FROM cache WHERE sourceLanguage=? AND targetLanguage=? AND sourceText=? AND hash IS NULL",
        [sourceLanguage, targetLanguage, text]
      )
    }
    
		if let result = try prepare.scalar() {
			return result as? String
		} else {
			return nil
		}
	}
	
  private func insertCache(hash: String?, sourceText: String, sourceLanguage: String, targetText: String, targetLanguage: String) throws {
		try createDatabaseIfNotExists()
		let db = try Connection(cacheURL.path)
		try db.run("INSERT INTO cache (hash, sourceLanguage, targetLanguage, sourceText, targetText) VALUES (?, ?, ?, ?, ?)", [hash, sourceLanguage, targetLanguage, sourceText, targetText])
	}
}
