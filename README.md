```swift
import Foundation
import Translator

let deepL = DeepLTextTranslator(apiKey: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx:xx")
print(try? deepL.translate(text: "リンゴ", from: "ja", to: "en"))

let google = GoogleTextTranslator(apiKey: "xxxxxxxxxxxxxxxxxx-xxxxxxxxxxxxxx-xxxxx")
print(try? google.translate(text: "ミカン", from: "ja", to: "en"))

let hybrid = HybridTextTranslator(translators: [deepL, google])
print(try? hybrid.translate(text: "ブドウ", from: "ja", to: "en"))

let cached = CachedTextTranslator(translator: hybrid, cacheURL: URL(fileURLWithPath: "a.sqlite"))
print(try? cached.translate(text: "イチゴ", from: "ja", to: "en"))
```
