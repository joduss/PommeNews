//
//  ThemeClassifier.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import ArticleClassifierCore


public class ThemeClassifier {
    
    private let classifierTermsGenerator = ThemeClassifierTermsMultiLocalization()
    
    private let minimumCharacterForWholeTextTermSearch = 4 //To avoid bigmac to be classify as a mac. Splitting is not hurt since search is made on exact match
    
    private var validThemes = ArticleTheme.allThemes
    
    private var themesClassifiers: [ArticleTheme : [String]] = [:]

    
    public init(validThemes: [ArticleTheme]) {
        self.validThemes = validThemes
        themesClassifiers = buildClassifiers(allThemes: classifierTermsGenerator.generateClassifierTerms())
    }
    
    public init() {
        themesClassifiers = buildClassifiers(allThemes: classifierTermsGenerator.generateClassifierTerms())
    }
    
    public func classify(article: TCArticle) -> [ArticleTheme] {
        
        let title = processedText(article.title)
        let summary = processedText(article.summary)

        
        let fullTextClassificationTitle = self.classifyAsFullText(text: title)
        let fullTextClassificationSummary = self.classifyAsFullText(text: summary)
        let classificationByBreakingTitle = self.classifyBreakingInSeparateWord(text: title)
        let classificationByBreakingSummary = self.classifyBreakingInSeparateWord(text: summary)
        
        var themes = Set<ArticleTheme>()
        themes = themes.union(fullTextClassificationTitle)
        themes = themes.union(fullTextClassificationSummary)
        themes = themes.union(classificationByBreakingTitle)
        themes = themes.union(classificationByBreakingSummary)
        
        if themes.isEmpty {
            themes.insert(ArticleTheme.other)
        }
        
        return Array(themes)
    }
    
    private func classifyAsFullText(text: String) -> [ArticleTheme] {

        var themesFound: [ArticleTheme] = []
        
        for themeClassifiers in themesClassifiers {
                        
            if containsText(text, partOfClassifierTerms: themeClassifiers.value) {
                themesFound.append(themeClassifiers.key)
            }
        }
        return themesFound
    }
    
    private func classifyBreakingInSeparateWord(text: String) -> [ArticleTheme] {
        
        let textComponents = text.lowercased().components(separatedBy: CharacterSet.punctuationCharacters.union(CharacterSet.whitespacesAndNewlines))
        
        var themesFound: [ArticleTheme] = []

        for themeClassifiers in themesClassifiers {
            if hasAComponentOf(textComponents: textComponents, partOfClassifierTerms: themeClassifiers.value) {
                themesFound.append(themeClassifiers.key)
            }
        }
        return themesFound
    }
    
    private func hasAComponentOf(textComponents: [String], partOfClassifierTerms terms: [String]) -> Bool {
        for classifierTerm in terms {
            if textComponents.filter({!$0.isEmpty}).contains(classifierTerm) {
                return true
            }
        }
        return false
    }
    
    /// Check if the text contains one classifier term
    private func containsText(_ text: String, partOfClassifierTerms terms: [String]) -> Bool {
        
        for classifierTerm in terms {
            if text.contains(classifierTerm) {
                return true
            }
        }
        return false
    }
    
    private func processedText(_ text: String) -> String {
        var processText = text.lowercased()
        processText = processText.replacingOccurrences(of: "d'", with: " ")
        processText = processText.replacingOccurrences(of: "l'", with: " ")
        processText = processText.replacingOccurrences(of: " the ", with: " ")
        processText = processText.replacingOccurrences(of: " le ", with: " ")
        processText = processText.replacingOccurrences(of: " la ", with: " ")
        processText = processText.replacingOccurrences(of: " of ", with: " ")
        processText = processText.replacingOccurrences(of: " de ", with: " ")
        processText = processText.replacingOccurrences(of: " les ", with: " ")
        processText = processText.replacingOccurrences(of: " des ", with: " ")
        processText = processText.replacingOccurrences(of: " a ", with: " ")
        processText = processText.replacingOccurrences(of: " on ", with: " ")
        processText = processText.replacingOccurrences(of: " from ", with: " ")
        
        return processText
    }
    
    private func buildClassifiers(allThemes: [ArticleTheme : [String]]) -> [ArticleTheme : [String]] {
        var themesLeft:[ArticleTheme : [String]] = [:]
        
        for theme in validThemes {
            themesLeft[theme] = allThemes[theme]
        }
        
        return themesLeft
    }
    
}
