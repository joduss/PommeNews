import Foundation
import NaturalLanguage

public class ACTextPreprocessor {
    
    private let language: NLLanguage
    private let lemmatizer: ACLemmatizer
    
    public init(representativeText: String) {
        let languageRecognizer = NLLanguageRecognizer()
        languageRecognizer.processString(representativeText)
        language = languageRecognizer.dominantLanguage!
        lemmatizer = ACLemmatizer(language: language)
    }
    
    public func process(text: String) -> String {
        return lemmatizer.lemmatize(text: text, removeStopWords: true)
    }
}
