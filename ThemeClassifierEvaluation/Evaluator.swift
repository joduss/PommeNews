//
//  Evaluator.swift
//  PommeNews
//
//  Created by Jonathan Duss on 04.09.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


class Evaluator {
    
    private let articlesIO = ArticlesJsonFileIO()
    
    //TODO filter the theme of the article as well!

    
    
    public func startEvaluation(articleLocation: String, themes: [ArticleTheme] = ArticleTheme.allThemes) {
        
        var usedThemes = themes
        
        if themes.contains(ArticleTheme.other) == false {
            usedThemes.append(ArticleTheme.other)
        }
        
        let articlesAllThemes = try! articlesIO.loadArticlesFrom(fileLocation: articleLocation)
        let articles = removeUnusedThemes(articlesAllThemes, usedThemes: themes)
        
        let classifier = ThemeClassifier()
        classifier.validThemes = themes
        
        var nbArticleCorrect: Double = 0
        var nbArticle100Correct: Double = 0
        var nbArticleMissingThemes: Double = 0
        var nbArticlesIncorrectThemes: Double = 0
        var nbArticleSomeCorrectThemes: Double = 0
        
        var ratioThemeFoundVsNotFoundAvg: Double = 0
        var ratioThemeIncorrectVsCorrectAvg: Double = 0
        
        let nbArticles: Double = Double(articles.count)
        
        let nbArticleWithGivenThemes: Double = Double(articles.filter({ article in
            for theme in themes {
                if article.themes.contains(theme.key) {
                    return true
                }
            }
            return false
        }).count)
        
        var processed = 0.0
        for article in articles {
            
            
            let predictedThemes = classifier.classify(article: article)
            
            
            let nbIncorrect = incorrectThemes(predicted: predictedThemes, truth: article.themes)
            if nbIncorrect > 0 {
                nbArticlesIncorrectThemes += 1
            }
            
            let nbCorrect = correctThemes(predicted: predictedThemes, truth: article.themes)
            if nbCorrect == 0 {
                nbArticleCorrect += 1
            }
            else {
                nbArticleSomeCorrectThemes += 1
                if Int(nbCorrect) == article.themes.count {
                    nbArticle100Correct += 1
                }
            }
            
            let ratioCorrectness = nbCorrect != 0 ? (nbIncorrect / nbCorrect) : 1
            ratioThemeIncorrectVsCorrectAvg += ratioCorrectness / nbArticles
            
            let nbMissing = missingThemes(predicted: predictedThemes, truth: article.themes)
            if nbMissing > 0 {
                nbArticleMissingThemes+=1
            }
            
            let ratioPredictedVsExpected = (nbCorrect / Double(article.themes.count))
            print("\(ratioPredictedVsExpected)")
            ratioThemeFoundVsNotFoundAvg += ratioPredictedVsExpected / nbArticles
            
            processed += 1
            print("Processed \(Int(processed)) (\(Int(Double(processed / nbArticles) * 100.0))%)")
        }
        
        print("Classifier Evaluation")
        print("=====================")

        print("Number of articles: \(nbArticles)")
        print("Number of articles with given themes: \(nbArticleWithGivenThemes)")
        print("---")
        print("# correct predictions \(nbArticleSomeCorrectThemes) (\(nbArticleSomeCorrectThemes / nbArticles * 100))")
        print("# 100% correct prediction \(nbArticle100Correct) (\(nbArticle100Correct / nbArticles * 100))")
        print("---")
        print("With missing themes [other exc.] \(nbArticleMissingThemes) (\(nbArticleMissingThemes / nbArticles * 100))")
        print("---")

        print("# with incorrect predictions [other exc.] \(nbArticlesIncorrectThemes) (\(nbArticlesIncorrectThemes / nbArticles * 100))")
        print("----------------")
        print("Ratios")
        print("Theme Found(correct) / Truth in avg. \(ratioThemeFoundVsNotFoundAvg) [1 Is best]")
        print("Theme incorrect / correct in avg. \(ratioThemeIncorrectVsCorrectAvg) [0 is best]")
        
        exit(0)
    }
    
    
    public func bla(articleLocation: String, themes: [ArticleTheme] = ArticleTheme.allThemes) {

        var predictions: [TCArticle: [ArticleTheme]] = [:]
        
        let classifier = ThemeClassifier()
        classifier.validThemes = themes
        
        let themesWithOther = themes + [ArticleTheme.other]

        let articlesAllThemes = try! articlesIO.loadArticlesFrom(fileLocation: articleLocation)
        
        //We still keep article with other (these should not be classify as something else than other
        let articles = removeUnusedThemes(articlesAllThemes, usedThemes: themesWithOther)


        for article in articles {
            predictions[article] = classifier.classify(article: article)
        }
    }
    
    private func analyzeCorrectness(predictions: [TCArticle: [ArticleTheme]], themes: [ArticleTheme]) {
        
        for theme in themes {
            let nbTruth = predictions.keys.reduce(0, { result, article in
                return article.themes.contains(theme.key) ? result + 1 : result
            })
            
            let nbOther = predictions.count - nbTruth
            
            let nbTruePositives =
            
            
        }
    }
    
    //=====================================================
    // Check theme prediction
    
    private func correctThemes(predicted: [ArticleTheme], truth: [String]) -> Double {
        var n = 0
        for theme in predicted {
            if truth.contains(theme.key) {
                n+=1
            }
        }
        return Double(n)
    }
    
    private func incorrectThemes(predicted: [ArticleTheme], truth: [String]) -> Double {
        var n = 0
        for theme in predicted {
            if truth.contains(theme.key) == false {
                n+=1
            }
        }
        return Double(n)
    }
    
    private func missingThemes(predicted: [ArticleTheme], truth: [String]) -> Double {
        var n = 0
        let predictedThemeKey: [String] = predicted.map({$0.key})
        for theme in truth {
            if predictedThemeKey.contains(theme) == false {
                n+=1
            }
        }
        return Double(n)
    }
    
    private func truePositiveCounter(predictions: [TCArticle: [ArticleTheme]], theme: ArticleTheme) -> Int {
        return predictions
            .filter({$0.key.themes.contains(theme.key)})
            .filter({$0.value.contains(theme)})
            .count
    }
    
    private func falsePositiveCounter(predictions: [TCArticle: [ArticleTheme]], theme: ArticleTheme) -> Int {
        return predictions
        .filter({$0.key.themes.contains(theme.key) == false})
        .filter({$0.value.contains(theme)})
        .count
    }
    
    private func trueNegativeCounter(predictions: [TCArticle: [ArticleTheme]], theme: ArticleTheme) -> Int {
        return predictions
            .filter({$0.key.themes.contains(theme.key) == false})
            .filter({$0.value.contains(theme) == false})
            .count
    }
    
    private func falseNegativeCounter(predictions: [TCArticle: [ArticleTheme]], theme: ArticleTheme) -> Int {
        return predictions
            .filter({$0.key.themes.contains(theme.key)})
            .filter({$0.value.contains(theme) == false})
            .count
    }
    
    //=====================================================
    // Utils
    private func removeUnusedThemes(_ articles: [TCArticle], usedThemes: [ArticleTheme]) -> [TCArticle] {
        var filteredArticles: [TCArticle] = []
        
        var usedThemesKeys: [String] = usedThemes.map({$0.key})
        
        for article in articles {
            var articleUsedThemeKeys: [String] = []
            for themeKey in article.themes {
                if usedThemesKeys.contains(themeKey) {
                    articleUsedThemeKeys.append(themeKey)
                }
            }
            if articleUsedThemeKeys.isEmpty {
                articleUsedThemeKeys.append(ArticleTheme.other.key)
            }
            filteredArticles += [TCArticle(title: article.title,
                                         summary: article.summary,
                                         themes: articleUsedThemeKeys)]
        }
        
        return filteredArticles
    }
}
