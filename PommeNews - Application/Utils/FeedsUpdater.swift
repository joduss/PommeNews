//
//  CompletionPubSub.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.01.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import CoreData
import NSLoggerSwift


///Handle updates of articles from the feeds
class FeedsUpdater {
    
    private let classifier: ThemeClassifier
    private let rssClient: RSSClient
    
    private var performing = false
    private var semaphore = DispatchSemaphore(value: 1)
    private var listeners: [AnyHashable: (Result<Void>) -> ()] = [:]
    
    private weak var rssManager: RSSManager!
    
    
    init(rssManager: RSSManager, classifier: ThemeClassifier, rssClient: RSSClient) {
        self.rssManager = rssManager
        self.classifier = classifier
        self.rssClient = rssClient
    }
    
    //MARK: - Public Perform Update
    //===================================================================
    
    public func update(feeds: [RssFeed]) {
        updateIfNotStarted(feeds: feeds)
    }
    
    public func updateAllFeeds() {
        updateIfNotStarted(feeds: rssManager.feeds)
    }
    
    //MARK: - Fetch the articles
    //===================================================================
    
    private func updateIfNotStarted(feeds: [RssFeed]) {
        semaphore.wait()
        guard performing != true else { return }
        performing = true
        
        semaphore.signal()
        
        self.performUpdate(feeds: feeds)
        
        semaphore.wait()
        performing = false
        semaphore.signal()
    }
    
    private func performUpdate(feeds: [RssFeed]) {
        DispatchQueue(label: "FeedUpdateGroup").async {
            
            let group = DispatchGroup()
            
            var errors: [RssFeed : PError] = [:]
            var updatedFeeds: [RssFeed] = []
            
            for feed in feeds {
                group.enter()
                
                self.update(feed: feed, completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let error):
                        errors[feed] = error
                    }
                    updatedFeeds.append(feed)
                    
                    group.leave()
                })
            }
            
            let timeout = group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(PommeNewsConfig.FeedUpdateTimeout))
            
            try? CoreDataStack.shared.save()
            
            guard timeout !=  DispatchTimeoutResult.timedOut else {
                self.handleTimeout(updatedFeeds: updatedFeeds, feedsToUpdate: feeds)
                return
            }
            
            //Handles the results
            if feeds.count == errors.count, let firstError = errors.first?.value {
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
    
    private func update(feed: RssFeed, completion: @escaping (Result<Void>) -> ()) {
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
                completion(.success)
                break
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    private func handleTimeout(updatedFeeds: [RssFeed], feedsToUpdate: [RssFeed]) {
        var notUpdatedFeeds = Set(feedsToUpdate)
        updatedFeeds.forEach({notUpdatedFeeds.remove($0)})
        
        var message = "The following feeds couldn't be updated:"
        notUpdatedFeeds.forEach({message += "\n- \($0.name)"})
        Logger.shared.log(Logger.Domain.service, Logger.Level.info, message)
        
        self.notifyFailure(error: PError.MultiFeedFetchingError(PError.HTTPErrorTimeout(message)))
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
    
    public func subscribeToArticlesUpdate(subscriber: AnyHashable, onPublish: @escaping (Result<Void>) -> () ) {
        
        guard listeners.keys.contains(subscriber) == false else { return }
        listeners[subscriber] = onPublish
    }
    
    public func unsubscribeFromArticlesupdate(_ unsubscriber: AnyHashable) {
        listeners.removeValue(forKey: unsubscriber)
    }
    
    private func notifyFailure(error: PError) {
        let result = Result<Void>.failure(error)
        listeners.forEach({ listener in
            DispatchQueue.main.async{ listener.value(result) }
        })
    }
    
    private func notifySuccess() {
        let result: Result<Void> = Result.success
        listeners.forEach({ listener in
            DispatchQueue.main.async{ listener.value(result) }
        })
    }
    
    //===================================================================
    
}
