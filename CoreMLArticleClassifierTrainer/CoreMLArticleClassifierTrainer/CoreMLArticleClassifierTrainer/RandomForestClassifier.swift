//
//  RandomForestClassifier.swift
//  CoreMLArticleClassifierTrainer
//
//  Created by Jonathan Duss on 01.08.19.
//  Copyright © 2019 ZaJo. All rights reserved.
//

import Foundation
import ArticleClassifierCore
import CreateML
import NaturalLanguage


class RandomForestClassifier {
    
    private let ColumnText = "text"
    private let ColumnTheme = "theme"
    let articlesFilePath = Bundle.main.path(forResource: "articles_fr", ofType: "json", inDirectory: nil)!
    
    private var articles: [TCArticle] = []
    private let lemmaTokenizer: ACLemmaTokenizer = ACLemmaTokenizer()
    
    func execute() {
        articles = try! ArticlesJsonFileIO().loadArticlesFrom(fileLocation: articlesFilePath)
            .filter({!$0.themes.isEmpty})
            .map({article in
                let title = lemmaTokenizer.lemmatize(text: article.title)
                let summary = lemmaTokenizer.lemmatize(text: article.summary)
                return TCArticle(title: title, summary: summary, themes: article.themes)
            })
            .shuffled()
    }
}
