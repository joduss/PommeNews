//
//  TfIdf.swift
//  ArticleClassifierCore-macos
//
//  Created by Jonathan Duss on 02.03.19.
//

import Foundation
import ZaJoLibrary
import NaturalLanguage


public class TfIdf {
    
    //======================================================================
    // MARK: - Caching
    
    //Cache for Dictionary of terms associated with the number of document that contains them.
    private var _termsDocumentFrequency: [String: Int] = [:]
    private var _idf: ContiguousArray<Double>?
    private var _allTermsVectorCached: ContiguousArray<String>?
    
    public var importantTerms: [String] = []

    //======================================================================
    // MARK: - Properties
    
    ///Dictionary of terms associated with the number of document that contains them.
    private(set) public var termsDocumentFrequency: [String: Int] {
        get {
            if (_termsDocumentFrequency.isEmpty) {
                computeTermAndTextContainingTerm()
            }
            return _termsDocumentFrequency
        }
        set {
            _termsDocumentFrequency = newValue
        }
    }

    private var textsHashCode: [Int]
    private(set) public var texts: [String]
    
    
    
    public var allTermsVector: ContiguousArray<String> {
        if _allTermsVectorCached == nil {
            _allTermsVectorCached = ContiguousArray(termsDocumentFrequency.keys.sorted())
        }
        return _allTermsVectorCached!
    }
    
    public var allTerms: Set<String> {
        return Set(termsDocumentFrequency.keys)
    }
    
    private var termCount: Int {
        return termsDocumentFrequency.count
    }
    
    //======================================================================
    // MARK: - Initialization
    
    
    /// Init a TfIdf object with the given set of texts. This should be a non-exhautive
    /// list of texts. A list of terms will be generated, therefore if not all texts are added,
    /// other texts might have terms that have never been encountered and will be ignored.
    ///
    /// Each document should be lowercased!
    ///
    /// - Parameter texts: The lowercased texts.
    public init(texts: [String]) {
        self.texts = texts.map({$0.lowercased()})
        textsHashCode = texts.map({$0.hashValue})
    }
    
    //======================================================================
    // MARK: - Perform computation for caching
    
    private func computeTermAndTextContainingTerm() {
        guard _termsDocumentFrequency.isEmpty else {
            return
        }
        
        for text in texts {
            for term in self.termsIn(text: text) {
                if let textContainingTerm = self._termsDocumentFrequency[term] {
                    self._termsDocumentFrequency[term] = textContainingTerm + 1
                }
                else {
                    self._termsDocumentFrequency[term] = 1;
                }
            }
        }
    }
    
    //======================================================================
    // MARK: - Modification operations on this tfIdf
    
    //======================================================================
    // MARK: - TF IDF

    
    /// Compute the frequency of each known terms
    ///
    /// - Parameter text: <#text description#>
    /// - Returns: <#return value description#>
    public func termFrequencyVector(text: String) -> ContiguousArray<Int> {
        var vector = ContiguousArray<Int>()
        
        var termFreqInText: [String : Int] = termFrequencyInText(text: text)
        
        Performance.measure(title: "append terms") {
            vector = []
            vector.reserveCapacity(termCount / 3)
            for term in allTermsVector {
                vector.append(termFreqInText[term] ?? 0)
            }
        }

        return vector
    }
    
    public func invertedDocumentFrequencyVector() -> ContiguousArray<Double> {
        
        if let idf = self._idf {
            return idf
        }
        
        let numberOfTerms = texts.count
        var idfVector: ContiguousArray<Double> = []
        idfVector.reserveCapacity(termCount)
        
        for term in allTermsVector {
            if importantTerms.contains(term) {
                idfVector.append(1)
                continue
            }
            let termDocumentFrequency = termsDocumentFrequency[term]!
            let idf = log(Double(numberOfTerms) / Double(termDocumentFrequency)) //no risk of division by 0. A term is always included in at least 1 text.
            idfVector.append(idf)
        }
        self._idf = idfVector
        return idfVector
    }
    
    public func tfIdfVector(text: String) ->  ContiguousArray<Double> {
        var tf: ContiguousArray<Int>!
        var idf: ContiguousArray<Double>!
        var results: ContiguousArray<Double>!
        
        Performance.measure(title: "tf") {
            tf = termFrequencyVector(text: text.lowercased())
        }
        Performance.measure(title: "idf") {
            idf = invertedDocumentFrequencyVector()
        }
        Performance.measure(title: "tf*idf") {
            results = tf.HadamarProduct(secondArray: idf)
        }
        return results
    }
    
    //======================================================================
    // MARK: - String Utility
    
    /// Tokenizes. Expects lowercased text!
    public func tokenize(_ text: String) -> [String] {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        var tokens: [String] = []
        tokens.reserveCapacity(text.count / 3)
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex, using: { (range, _) in
            let term = String(text[range])
            
            if (tokens.last == "ios") {
                tokens.append("ios \(term)")
            }
            else {
                tokens.append(term)
            }

            return true
        })
        
        return tokens
    }
    
    private var lemmatizerHelper: [String] = ["ios", "android", "windows", "iphone", "pixel"]
    
    /// Returns a dictionary of word along with their frequency. Expect lowercased text!
    public func termFrequencyInText(text: String) -> [String: Int] {
        
        var mutableText = text
        
        var tokens: [String: Int] = [:]
        tokens.reserveCapacity(mutableText.count / 3)
        
//        let tokenizer = NLTokenizer(unit: .word)
//        tokenizer.string = text
        
        let tagger = NLTagger(tagSchemes: [.lemma])
        
        var previous = ""
        
        
//        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex, using: { (range, attribute) in
//            let term = String(text[range])
//            if attribute == .numeric && lemmatizerHelper.contains(previous) {
//                let concatenedTerm = "\(previous) \(term)"
//                tokens[concatenedTerm] = 1 + (tokens[concatenedTerm] ?? 0)
//            }
//            else {
//                tokens[term] = 1 + (tokens[term] ?? 0)
//            }
//            previous = term
//            return true
//        })
        
//        text.enumerateSubstrings(
//            in: text.startIndex..<text.endIndex,
//            options: .byWords,
//            { (term, _, _, _) in
//                guard let term = term else { return }
//                tokens[term] = 1 + (tokens[term] ?? 0)
//        }
//        )
        
        let otherLemma: [String : String] = ["apps" : "application",
                                             "app" : "app"]
        
        let togethers: [(String, String)] = [("mac app store", "macappstore store"),
                                             ("app store", "appstore store"),
                                             ("itunes store", "itunesstore store"),
                                             ("iphone xs", "iphonexs iphone"),
                                             ("iphone xr", "iphonexr iphone"),
                                             ("iphone x", "iphonex iphone"),
                                             ("pixel 3a", "pixel3a pixel"),
                                             ("galaxy s9", "galaxys9"),
                                              ("galaxy s10", "galaxy s10")]
                                                
        for together in togethers {
            mutableText = mutableText.replacingOccurrences(of: together.0, with: together.1)
        }
        
        tagger.string = mutableText
        tagger.enumerateTags(in: mutableText.startIndex..<mutableText.endIndex,
                             unit: .word,
                             scheme: .lemma,
                             options: [.omitPunctuation, .omitWhitespace],
                             using: { tag, range in
                                let normal = String(mutableText[range])
                                let term = tag?.rawValue.lowercased() ?? otherLemma[normal] ?? normal

                                if term.count == 0 {
                                    return true
                                }

                                if Double(term) ?? 0 > 0 && lemmatizerHelper.contains(previous) {
                                    let concatenedTerm = "\(previous) \(term)"
                                    tokens[concatenedTerm] = 1 + (tokens[concatenedTerm] ?? 0)
                                }
                                else {
                                    tokens[term] = 1 + (tokens[term] ?? 0)
                                }
                                previous = term
                                return true
        })
        
        return tokens
    }
    
    public func termsIn(text: String) -> Set<String> {
        var tokens: Set<String> = []
        tokens.reserveCapacity(text.count / 4)

        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: .byWords,
            { (term, _, _, _) in
                guard let term = term else { return }
                tokens.insert(term.lowercased())
        }
        )
        return tokens
    }
    
    public func termVector(from text: String) -> [String] {
        return termsIn(text: text).sorted()
    }
    
    
    
    
}
