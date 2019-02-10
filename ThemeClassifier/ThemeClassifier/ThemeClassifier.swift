//
//  ThemeClassifier.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


class ThemeClassifier {
    
    private let classifierTermsGenerator = ThemeClassifierTermsMultiLocalization()
    
    private let minimumCharacterForWholeTextTermSearch = 4 //To avoid bigmac to be classify as a mac. Splitting is not hurt since search is made on exact match
    
    var validThemes = ArticleTheme.allThemes
    
    
    func classify(article: TCArticle) -> [ArticleTheme] {
        
        let title = processedText(article.title)
        let summary = processedText(article.summary)

        
        let fullTextClassificationTitle = self.classifyAsFullText(text: title)
        let fullTextClassificationSummary = self.classifyAsFullText(text: summary)
        let classificationByBreakingTitle = self.classifyBreakingInSeparateWord(text: title)
        let classificationByBreakingSummary = self.classifyBreakingInSeparateWord(text: summary)
        
        var themes = [ArticleTheme]()
        themes.append(contentsOf: fullTextClassificationTitle)
        themes.append(contentsOf: fullTextClassificationSummary)
        themes.append(contentsOf: classificationByBreakingTitle)
        themes.append(contentsOf: classificationByBreakingSummary)

        var alreadyAdded: [ArticleTheme : Bool] = [:]
        
        //Return uniques
        var allThemes = themes.filter({ theme in alreadyAdded.updateValue(true, forKey: theme) ?? false})
        
        if allThemes.isEmpty {
            allThemes.append(ArticleTheme.other)
        }
        
        return allThemes
    }
    
    private func classifyAsFullText(text: String) -> [ArticleTheme] {
        
        let themesClassifiers = limitThemes(allThemes: classifierTermsGenerator.generateClassifierTerms())
        

        var themesFound: [ArticleTheme] = []
        
        for themeClassifiers in themesClassifiers {
                        
            if containsText(text, partOfClassifierTerms: themeClassifiers.value) {
                themesFound.append(themeClassifiers.key)
            }
        }
        return themesFound
    }
    
    private func classifyBreakingInSeparateWord(text: String) -> [ArticleTheme] {
        
        let themesClassifiers = limitThemes(allThemes: classifierTermsGenerator.generateClassifierTerms())
        let textComponents = text.lowercased().components(separatedBy: CharacterSet.punctuationCharacters)
        
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
            if textComponents.contains(classifierTerm) {
                return true
            }
        }
        return false
    }
    
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
        processText = processText.replacingOccurrences(of: " d'", with: "")
        processText = processText.replacingOccurrences(of: " l'", with: " ")
        processText = processText.replacingOccurrences(of: " the ", with: " ")
        processText = processText.replacingOccurrences(of: " le ", with: " ")
        processText = processText.replacingOccurrences(of: " la ", with: " ")
        processText = processText.replacingOccurrences(of: " of ", with: " ")
        processText = processText.replacingOccurrences(of: " de ", with: " ")
        processText = processText.replacingOccurrences(of: ".", with: " ")
        processText = processText.replacingOccurrences(of: ",", with: " ")
        processText = processText.replacingOccurrences(of: ";", with: " ")
        
        return processText
    }
    
    private func limitThemes(allThemes: [ArticleTheme : [String]]) -> [ArticleTheme : [String]] {
        var themesLeft:[ArticleTheme : [String]] = [:]
        
        for theme in validThemes {
            themesLeft[theme] = allThemes[theme]
        }
        
        return themesLeft
    }
    
}
