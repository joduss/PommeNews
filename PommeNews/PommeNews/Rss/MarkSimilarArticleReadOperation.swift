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
    let articleLowercasedTitle: String
    let articleDate: Date
    
    init(article: RssArticle, tfIdf: TfIdf) {
        self.articleLowercasedTitle = article.title.lowercased()
        self.articleDate = article.date as Date
        self.tfIdf = tfIdf
    }
    
    override func main() {
        markRead()
    }
    
    private func markRead() {
        
        /// This is called by another thread! So we must ask the container to give us a context for background task!
        CoreDataStack.shared.persistentContainer.performBackgroundTask {
            context in
        
            let articleTfIdf = self.tfIdf.tfIdfVector(text: self.articleLowercasedTitle)
            
            let articles = ArticleRequest.init().execute(context: context)
            
            //Not to scan all the articles, we limit a time period of +/- 48 hours.
            //It is meaning full. Usually, same articles are published within a very short time. Less than 48h.
            
            for secondArticle in articles.filter({$0.date.timeIntervalSince(self.articleDate).magnitude < 3600 * 48}) {
                
                let secondArticleTfIdf = self.tfIdf.tfIdfVector(text: secondArticle.title.lowercased())
                let sim = CosineSimilarity.compute(vector1: articleTfIdf, vector2: secondArticleTfIdf)
                
                if sim > 0.5 {
                    OperationQueue.main.addOperation {
                        secondArticle.readLikelihood = Float(sim)
                    }
                }
            }
        }
    }
}
