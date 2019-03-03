//
//  TfIdf.swift
//  ArticleClassifierCore-macos
//
//  Created by Jonathan Duss on 02.03.19.
//

import Foundation
import ZaJoLibrary



public class TfIdf {
    
    //cache
    private var _termsTextContainingTerm: [String: Int] = [:]

    
    private(set) public var termsTextContainingTerm: [String: Int] {
        get {
            if (_termsTextContainingTerm.isEmpty) {
                computeTermAndTextContainingTerm()
            }
            return _termsTextContainingTerm
        }
        set {
            _termsTextContainingTerm = newValue
        }
    }

    
    public var allTermsVector: [String] {
        return termsTextContainingTerm.keys.sorted()
    }
    
    public var allTerms: Set<String> {
        return Set(termsTextContainingTerm.keys)
    }

    
    private(set) public var texts: [String]
    let textsHashCode: [Int]
    
    
    init(texts: [String]) {
        self.texts = texts
        textsHashCode = texts.map({$0.hashValue})
    }
    
    public func getTfIdfVector(text: String) ->[Int] {
//        var terms = extractAllTerms(text: text)
//        
//        var vector: [Int] = []
//        
//        for term in terms {
//            
//        }
        return [0]
    }
    
    private func computeTermAndTextContainingTerm() {
        guard _termsTextContainingTerm.isEmpty else {
            return
        }
        
        for text in texts {
            for term in self.termsIn(text: text) {
                
                if let textContainingTerm = self._termsTextContainingTerm[term] {
                    self._termsTextContainingTerm[term] = textContainingTerm + 1
                }
                else {
                    self._termsTextContainingTerm[term] = 1;
                }
            }
        }
    }
        
        
    public func getTerms() -> Set<String> {
        guard termsTextContainingTerm.isEmpty else {
            return Set(termsTextContainingTerm.keys)
        }
        
        computeTermAndTextContainingTerm()
        
        return Set(termsTextContainingTerm.keys)
    }
    
    public func frequencyVector(text: String) -> [Int] {
        let tokenizedText = termsIn(text: text)
        
        var vector: [Int] = []
        
        for term in getTerms() {
            vector.append(tokenizedText.filter({$0 == term}).count)
        }
        
        return vector
    }
    
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
    
    public func termsVector(from text: String) -> [String] {
        return termsIn(text: text).sorted()
    }

    
    public func frequencyOf(term: String, in tokenizedText: [String]) {
        
    }

}
