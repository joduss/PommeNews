//
//  MarkSimilarArticleReadOperation.swift
//  PommeNews
//
//  Created by Jonathan Duss on 12.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import ArticleClassifierCore

///Mark similar article read as well
class MarkSimilarArticleReadOperation: Operation {

    private let tfIdf: TfIdf
    let article: RssArticle
    
    init(article: RssArticle, tfIdf: TfIdf) {
        self.article = article
        self.tfIdf = tfIdf
    }
    
    override func main() {
        markRead()
    }
    
    private func markRead() {
        let articleTfIdf = tfIdf.tfIdfVector(text: article.title + " - " + (article.summary ?? ""))
        
        let articles = ArticleRequest.init().execute(context: CoreDataStack.shared.context)
        
        //Not to scan all the articles, we limit a time period of 72 hours.
        //It is meaning full. Usually, same articles are published within a very short time. Less than 48h.
        
        for secondArticle in articles.filter({$0.date.timeIntervalSince(article.date as Date).magnitude < 3600 * 48}) {
            let secondArticleTfIdf = tfIdf.tfIdfVector(text: secondArticle.title + " - " + (secondArticle.summary ?? ""))
            
            let sim = CosineSimilarity.computer(vector1: articleTfIdf, vector2: secondArticleTfIdf)
            print("Sim: \(sim)")
        }
    }
    
}
