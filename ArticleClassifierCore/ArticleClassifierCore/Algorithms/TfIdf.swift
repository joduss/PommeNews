//
//  TfIdf.swift
//  ArticleClassifierCore-macos
//
//  Created by Jonathan Duss on 02.03.19.
//

import Foundation
import ZaJoLibrary



public class TfIdf {
    
    //======================================================================
    // MARK: - Caching
    
    //Cache for Dictionary of terms associated with the number of document that contains them.
    private var _termsDocumentFrequency: [String: Int] = [:]

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
    
    public var allTermsVector: [String] {
        return termsDocumentFrequency.keys.sorted()
    }
    
    public var allTerms: Set<String> {
        return Set(termsDocumentFrequency.keys)
    }
    
    //======================================================================
    // MARK: - Initialization
    
    init(texts: [String]) {
        self.texts = texts
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

    public func termFrequencyVector(text: String) -> [Int] {
        let tokenizedText = termsIn(text: text)
        
        var vector: [Int] = []
        
        for term in allTermsVector {
            vector.append(tokenizedText.filter({$0 == term}).count)
        }
        
        return vector
    }
    
    public func invertedDocumentFrequencyVector() -> [Double] {
        let numberOfTerms = texts.count
        var idfVector: [Double] = []
        
        for term in allTermsVector {
            let termDocumentFrequency = termsDocumentFrequency[term]!
            let idf = log(Double(numberOfTerms) / Double(termDocumentFrequency)) //no risk of division by 0. A term is always included in at least 1 text.
            idfVector.append(idf)
        }
        return idfVector
    }
    
    public func tfIdfVector(text: String) ->  [Double] {
        return termFrequencyVector(text: text).HadamarProduct(secondArray: invertedDocumentFrequencyVector())
    }
    
    //======================================================================
    // MARK: - String Utility
    
    public func tokenize(_ text: String) -> [String] {
        var tokens: [String] = []
        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: .byWords,
            { (term, _, _, _) in
                guard let term = term else { return }
                tokens.append(term.lowercased())
        }
        )
        
        return tokens
    }
    
    public func termsIn(text: String) -> Set<String> {
        var tokens: Set<String> = []
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
