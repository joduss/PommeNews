//
//  CoreMLTextClassifier.swift
//  CoreMLArticleClassifierTrainer
//
//  Created by Jonathan Duss on 01.08.19.
//  Copyright © 2019 ZaJo. All rights reserved.
//

import Foundation
import ArticleClassifierCore
import CreateML
import NaturalLanguage



/// This class creates a text classifier for a single theme.
/// It is working by polirazing the theme: it this this theme or other.
/// We would need to have many classifier: one per theme.
///
/// Bad results!
class CoreMLTextClassifier {
    
    private static let THEME = ArticleTheme.apple
    
    private let ColumnText = "text"
    private let ColumnTheme = "theme"
    let articlesFilePath = Bundle.main.path(forResource: "articles_fr", ofType: "json", inDirectory: nil)!
    
    private var articles: [TCArticle] = []
    private let lemmaTokenizer: ACLemmaTokenizer = ACLemmaTokenizer()
    
    /// Read this file in memory:
    
    init() {
        
        // Create the articles, lemmatized
        articles = try! ArticlesJsonFileIO().loadArticlesFrom(fileLocation: articlesFilePath)
            .filter({!$0.themes.isEmpty})
            .map({article in
                let title = lemmaTokenizer.lemmatize(text: article.title)
                let summary = lemmaTokenizer.lemmatize(text: article.summary)
                return TCArticle(title: title, summary: summary, themes: article.themes)
            })
            .shuffled()
        
        // Polazired the article for a given theme: THEME or OTHER.
        let theme = CoreMLTextClassifier.THEME
        
        let articlesForTheme: [TCArticle] = articles.map({ article in
            
            if article.themes.contains(theme.key) {
                return TCArticle(title: article.title, summary: article.summary, themes: [theme.key], associatedObject: nil)
            }
            return TCArticle(title: article.title, summary: article.summary, themes: [ArticleTheme.other.key], associatedObject: nil)
        })
        
        var table = MLDataTable()
        table.addColumn(MLDataColumn(articlesForTheme.map({$0.title})), named: ColumnText)
        table.addColumn(MLDataColumn(articlesForTheme.map({$0.themes.first!})), named: ColumnTheme)
        
        print(table)
        
        print("Classifier training...")
        print("======================")
        
        let (trainingData, testData) = table.randomSplit(by: 0.7)
        //        let (trainingDataTraining, trainingDataValidation) = trainingData.randomSplit(by: 0.05)
        
        
        /*
         let param = MLTextClassifier.ModelParameters.init(validationData: trainingDataValidation, algorithm: .crf(revision: 1), language: .french)
         */
        let classifier = try! MLTextClassifier(trainingData: trainingData, textColumn: ColumnText, labelColumn: ColumnTheme)
        
        // Training accuracy as a percentage
        let trainingAccuracy = (1.0 - classifier.trainingMetrics.classificationError) * 100
        
        // Validation accuracy as a percentage
        let validationAccuracy = (1.0 - classifier.validationMetrics.classificationError) * 100
        
        print("Training accurary: \(trainingAccuracy)")
        print("Validation accurary: \(validationAccuracy)")
        
        print("#####\n#####\n\n")
        
        print("Classifier testing...")
        print("======================")
        
        let evaluationMetrics = classifier.evaluation(on: testData)
        
        let testingAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
        print("Testing accuracy: \(testingAccuracy)\n")
        
        print(evaluationMetrics.precisionRecall)
        
        print("Confusion:")
        print("======================")
        print(evaluationMetrics.confusion)
        
    }
}
