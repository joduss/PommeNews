//
//  CompletionPubSub.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.01.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import CoreData

protocol RssManagerChangeListener: class {
    func updated()
    func updateFailed(error: PError)
}


///Handle updates of articles from the feeds
class FeedsUpdater {
    
    private let classifier: ThemeClassifier
    private let rssClient: RSSClient
    
    private var performing = false
    private var semaphore = DispatchSemaphore(value: 1)
    private var listeners: [RssManagerChangeListener] = []
    
    private weak var rssManager: RSSManager?
    
    
    init(rssManager: RSSManager, classifier: ThemeClassifier, rssClient: RSSClient) {
        self.rssManager = rssManager
        self.classifier = classifier
        self.rssClient = rssClient
    }
    
    //MARK: - Public Perform Update
    //===================================================================
    
    public func performUpdate(feedsList: [RssFeed]) {
        performIfNotStarted(feedsList: feedsList)
    }
    
    //MARK: - Fetch the articles
    //===================================================================
    
    private func performIfNotStarted(feedsList: [RssFeed]) {
        semaphore.wait()
        guard performing != true else { return }
        performing = true
        
        semaphore.signal()
        
        self.performAllFeedsUpdate(feedsList: feedsList)
        
        semaphore.wait()
        performing = false
        semaphore.signal()
    }
    
    private func performAllFeedsUpdate(feedsList: [RssFeed]) {
        DispatchQueue(label: "FeedUpdate").async {
            
            let group = DispatchGroup()
            
            var errors: [RssFeed : PError] = [:]
            
            for feed in feedsList {
                group.enter()
                
                self.update(feed: feed, completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        errors[feed] = error
                    }
                    
                    group.leave()
                })
                
            }
            
            let timeout = group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(120))
            
            try? CoreDataStack.shared.save()
            
            if timeout ==  DispatchTimeoutResult.timedOut {
                self.notifyFailure(error: PError.HTTPErrorTimeout)
            }
                
            if feedsList.count == errors.count, let firstError = errors.first?.value {
                self.notifyFailure(error: PError.MultiFeedFetchingError(firstError))
            }
            else if let singleError = errors.first?.value  {
                self.notifyFailure(error: singleError)
            }
            else {
                self.notifySuccess()
            }
        }
    }
    
    private func update(feed: RssFeed, completion: @escaping (Result<RssArticle>) -> ()) {
        let feedPO = RssPlistFeed(name: feed.name,
                                  url: feed.url.absoluteString,
                                  id: feed.id
        )
        
        self.rssClient.fetch(feed: feedPO, completion: { result in
            switch result {
            case .success(let articles):
                //TODO
                for article in articles {
                    self.save(article: article, fromFeed: feed)
                }
                break
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    //===================================================================
    
    
    //MARK: - Data Base management for the saved articles
    //===================================================================
    
    private func save(article articlePO: RssArticlePO, fromFeed feed: RssFeed) {
        
        DispatchQueue.main.async {
            
            guard self.exists(article: articlePO) == false else { return }
            
            let article: RssArticle = NSEntityDescription.insertNewObject(forEntityName: RssArticle.entityName, into: CoreDataStack.shared.context) as! RssArticle
            
            article.title = articlePO.title
            article.creator = articlePO.creator
            article.date = articlePO.date as NSDate
            article.feed = feed
            article.imageUrl = articlePO.imageUrl ?? articlePO.extractImageUrlFromSummary()
            article.link = articlePO.link
            article.summary = articlePO.summary
            article.read = false
            
            let articleForClassification = TCArticle(title: article.title,
                                                     summary: article.summary)
            let classification = self.classifier.classify(article: articleForClassification)
            
            let themesCD = Request<Theme>().execute(context: CoreDataStack.shared.context)
            
            for themeOfClassifier in classification {
                if let themeCD = themesCD.filter({$0.key == themeOfClassifier.key}).first {
                    article.addToThemes(themeCD)
                }
            }
        }
    }
    
    private func exists(article: RssArticlePO) -> Bool {
        let request: NSFetchRequest<RssArticle> = RssArticlesRequest().create()
        
        request.predicate = NSPredicate(format: "\(RssArticle.linkPropertyName) == %@", article.link?.absoluteString ?? "")
        
        do {
            return try CoreDataStack.shared.context.count(for: request) != 0
        } catch {
            //TODO
            return false
        }
    }
    
    //===================================================================
    
    
    //MARK: - PUB/SUB for article updates
    //===================================================================
    
    public func subscribeToArticlesUpdate(_ newSubscriber: RssManagerChangeListener) {
        guard listeners.contains(where: { $0 === newSubscriber }) == false else {
            return
        }
        listeners.append(newSubscriber)
    }
    
    public func unsubscribeFromArticlesupdate(_ unsubscriber: RssManagerChangeListener) {
        guard let idx = listeners.firstIndex(where: { $0 === unsubscriber }) else { return }
        listeners.remove(at: idx)
    }
    
    func notifyFailure(error: PError) {
        listeners.forEach({ $0.updateFailed(error: error) })
    }
    
    func notifySuccess() {
        listeners.forEach({ $0.updated() })
    }
    
    //===================================================================
    
}
