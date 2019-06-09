//
//  RSSManager.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit
import CoreData
import WebKit
import ArticleClassifier
import ArticleClassifierCore
import RssClient
import ZaJoLibrary

class RSSManager {
    
    struct Notifications {
        static let RssSitesUpdated = "RssSitesUpdated"
    }
    
    private struct StorageKeys {
        static let sitesToShow = "sitesToShow"
    }
    
    private let rssClient: RSSClient
    
    private let classifier = ThemeClassifier()
    private lazy var tfIdf: TfIdf = self.initializeTfIdf()

    
    private var lastUpdate = Date()
    private let context = CoreDataStack.shared.context
    
    public var feedsUpdater: FeedsUpdater! = nil
    
    public lazy var rssFeedStore: RssFeedStore = {
        return RssFeedStore(rssManager: self)
    }()
    
    init(rssClient: RSSClient) {
        
        self.rssClient = rssClient
        
        //Init Themes
        try! ThemeLoader().loadThemes()
        
        //TODO: Remove newly unsupported themes
        
        //Configure classifier
        let supportedThemes = Request<Theme>().execute(context: CoreDataStack.shared.context)
        classifier.validThemes = supportedThemes.map({ArticleTheme(key: $0.key)})

        self.feedsUpdater = FeedsUpdater(rssManager: self, classifier: self.classifier, rssClient: self.rssClient)
    }

    
    //MARK: - ONLINE
    //===================================================================

    func cleanCache() {
        let websitesData = WKWebsiteDataStore.allWebsiteDataTypes()
        
        WKWebsiteDataStore.default().removeData(ofTypes: websitesData,
                                                modifiedSince: Date(timeIntervalSinceReferenceDate: 0),
                                                completionHandler: { })
        do {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: RssArticle.fetchRequest())
            try context?.execute(deleteRequest)
            
        } catch {
            return
        }
    }
    
    lazy var operationQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "SimilarArticlesQueue"
        return queue
    }()
    
    func markRead(article: RssArticle) {
        let newMarkSimilarArticleReadOperation = MarkSimilarArticleReadOperation(article: article, tfIdf: tfIdf)
        if let lastOperation = operationQueue.operations.last {
            newMarkSimilarArticleReadOperation.addDependency(lastOperation)
        }
        
        operationQueue.addOperation(newMarkSimilarArticleReadOperation)
    }
    
    private func initializeTfIdf() -> TfIdf {
        var texts: [String] = []
        let articles = ArticleRequest.init().execute(context: CoreDataStack.shared.context)
        
        for article in articles {
            texts.append(article.title + " - " + (article.summary ?? ""))
        }
        
        return TfIdf(texts: texts)
    }
    
}
