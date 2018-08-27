//
//  ThemeClassifier.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


struct TCArticle {
    let title: String
    let summary: String
    let languageCode: String
}

class ThemeClassifier {
    
    let minimumCharacterForWholeTextTermSearch = 4 //To avoid bigmac to be classify as a mac. Splitting is not hurt since search is made on exact match
    
    let classifierTermsGenerator = ThemeClassifierTermsMultiLocalization()
    
    
    func classify(article: RssArticlePO) -> [ArticleTheme] {
        
        let fullTextClassificationTitle = self.classifyAsFullText(text: article.title)
        let fullTextClassificationSummary = self.classifyBreakingInSeparateWord(text: article.summary)
        let classificationByBreakingTitle = self.classifyBreakingInSeparateWord(text: article.title)
        let classificationByBreakingSummary = self.classifyBreakingInSeparateWord(text: article.summary)
        
        var themes = [ArticleTheme]()
        themes.append(contentsOf: fullTextClassificationTitle)
        themes.append(contentsOf: fullTextClassificationSummary)
        themes.append(contentsOf: classificationByBreakingTitle)
        themes.append(contentsOf: classificationByBreakingSummary)

        var alreadyAdded: [ArticleTheme : Bool] = [:]
        
        //Return uniques
        return themes.filter({ theme in alreadyAdded.updateValue(true, forKey: theme) ?? false})
    }
    
    ///Returns the Themes from which the classifier terms longer than "minimumCharacterForWholeTextTermSearch"
    ///can be found in the text
    private func classifyAsFullText(text: String) -> [ArticleTheme] {
        
        let themesClassifiers = classifierTermsGenerator.generateClassifierTerms()
        
        var articlesThemes: [ArticleTheme] = []
        
        for themeClassifiers in themesClassifiers {
            guard themeClassifiers.key.key.count > minimumCharacterForWholeTextTermSearch else { break }
            
            if hasAComponentOf(textComponents: [text], partOfClassifierTerms: themeClassifiers.value) {
                articlesThemes.append(themeClassifiers.key)
            }
        }
        return articlesThemes
    }
    
    private func classifyBreakingInSeparateWord(text: String) -> [ArticleTheme] {
        
        let themesClassifiers = classifierTermsGenerator.generateClassifierTerms()
        let textComponents = text.lowercased().components(separatedBy: CharacterSet.punctuationCharacters)
        
        var articlesThemes: [ArticleTheme] = []

        for themeClassifiers in themesClassifiers {
            if hasAComponentOf(textComponents: textComponents, partOfClassifierTerms: themeClassifiers.value) {
                articlesThemes.append(themeClassifiers.key)
            }
        }
        return articlesThemes
    }
    
    private func hasAComponentOf(textComponents: [String], partOfClassifierTerms terms: [String]) -> Bool {
        for classifierTerm in terms {
            if textComponents.contains(classifierTerm) {
                return true
            }
        }
        return false
    }
    
}
