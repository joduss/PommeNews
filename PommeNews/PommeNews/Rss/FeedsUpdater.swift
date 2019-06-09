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
import ArticleClassifier
import ArticleClassifierCore
import ZaJoLibrary
import RssClient

///Handle updates of articles from the feeds
class FeedsUpdater {
    
    private let classifier: ThemeClassifier
    private let rssClient: RSSClient
    
    private var performing = false
    private var semaphore = DispatchSemaphore(value: 1)
    private var listeners: [AnyHashable: (Result<Void, PError>) -> ()] = [:]
    
    private weak var rssManager: RSSManager!
    private var rssFeedStore: RssFeedStore!
    
    
    init(rssManager: RSSManager, classifier: ThemeClassifier, rssClient: RSSClient) {
        self.rssManager = rssManager
        self.classifier = classifier
        self.rssClient = rssClient
        self.rssFeedStore = rssManager.rssFeedStore
    }
    
    //MARK: - Public Perform Update
    //===================================================================
    
    public func update(feeds: [RssFeed]) {
        updateIfNotStarted(feeds: feeds)
    }
    
    public func updateAllFeeds() {
        updateIfNotStarted(feeds: rssFeedStore.feeds)
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
    
    /// Perform the update for the given list of feeds
    private func performUpdate(feeds feedsToUpdate: [RssFeed], completion: ((Bool) -> ())? = nil) {
        
        /* We need to do the update on another thread for performance reason.
         * Which means that we need as well a background context for coredata and that this context is passed all along.
         *
         */
        
        let feedsToUpdateIds = feedsToUpdate.map({$0.objectID})
        
        DispatchQueue(label: "FeedUpdateGroup").async {
            CoreDataStack.shared.persistentContainer.performBackgroundTask({ (context) in
                let feeds = feedsToUpdateIds.map({Request<RssFeed>.objectWithId(id: $0, context: context)})
                
                let dispatchGroup = DispatchGroup()
                
                var errors: [RssFeed : PError] = [:]
                var updatedFeeds: [RssFeed] = []
                
                // Updating each feed
                for feed in feeds {
                    dispatchGroup.enter()
                    
                    self.update(feed: feed, context: context, completion: { result in
                        switch result {
                        case .success(_): break
                        case .failure(let error):
                            errors[feed] = error
                        }
                        updatedFeeds.append(feed)
                        
                        dispatchGroup.leave()
                    })
                }
                
                let timeout = dispatchGroup.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(PommeNewsConfig.FeedUpdateTimeout))
                
                guard timeout !=  DispatchTimeoutResult.timedOut else {
                    self.handleTimeout(updatedFeeds: updatedFeeds, feedsToUpdate: feeds)
                    return
                }
                
                try? context.save()
                
                //Handles the results
                if feeds.count == errors.count, let firstError = errors.first?.value {
                    self.notifyFailure(error: PError.MultiFetchingError(firstError))
                }
                else if let singleError = errors.first?.value  {
                    self.notifyFailure(error: singleError)
                }
                else {
                    self.notifySuccess()
                }
            })
        }
    }
    
    /// Performs the update for the given feed
    private func update(feed: RssFeed, context: NSManagedObjectContext, completion: @escaping (Result<Void, PError>) -> ()) {
        let feedPO = RssPlistFeed(name: feed.name,
                                  url: feed.url.absoluteString,
                                  language: feed.language,
                                  id: feed.id
        )
        
        let semaphore = DispatchSemaphore(value: 0)
        var resultTemp: Result<[RssArticlePO], PError>?
        
        self.rssClient.fetch(feed: feedPO, completion: { resutInBlock in
            resultTemp = resutInBlock
            semaphore.signal()
        })
        
        semaphore.wait()
        
        guard let result = resultTemp else {
            completion(.failure(PError.unknownError("null? Why?")))
            return
        }
        
        switch result {
        case .success(let articles):
            for article in articles {
                self.save(article: article, fromFeed: feed, context: context)
            }
            completion(.success)
            break
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private func handleTimeout(updatedFeeds: [RssFeed], feedsToUpdate: [RssFeed]) {
        var notUpdatedFeeds = Set(feedsToUpdate)
        updatedFeeds.forEach({notUpdatedFeeds.remove($0)})
        
        var message = "The following feeds couldn't be updated:"
        notUpdatedFeeds.forEach({message += "\n- \($0.name)"})
        Logger.shared.log(Logger.Domain.service, Logger.Level.info, message)
        
        self.notifyFailure(error: PError.MultiFetchingError(PError.HTTPErrorTimeout(message)))
    }
    
    //===================================================================
    
    
    //MARK: - Data Base management for the saved articles
    //===================================================================
    
    /// Saves the article to the database.
    private func save(article articlePO: RssArticlePO, fromFeed feed: RssFeed, context: NSManagedObjectContext) {
        
        guard self.exists(article: articlePO, context: context) == false else { return }
        
        let article: RssArticle = NSEntityDescription.insertNewObject(forEntityName: RssArticle.entityName, into: context) as! RssArticle
        
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
        
        let themesCD = Request<Theme>().execute(context: context)
        
        for themeOfClassifier in classification {
            if let themeCD = themesCD.filter({$0.key == themeOfClassifier.key}).first {
                article.addToThemes(themeCD)
            }
        }
    }
    
    private func exists(article: RssArticlePO, context: NSManagedObjectContext) -> Bool {
        let request = Request<RssArticle>()
        request.and(NSPredicate(format: "\(RssArticle.linkPropertyName) == %@", article.link?.absoluteString ?? ""))

        do {
            return try context.count(for: request.fetchRequest()) != 0
        } catch {
            //TODO
            return false
        }
    }
    
    //===================================================================
    
    
    //MARK: - PUB/SUB for article updates
    //===================================================================
    
    public func subscribeToArticlesUpdate(subscriber: AnyHashable, onPublish: @escaping (Result<Void, PError>) -> () ) {
        
        guard listeners.keys.contains(subscriber) == false else { return }
        listeners[subscriber] = onPublish
    }
    
    public func unsubscribeFromArticlesupdate(_ unsubscriber: AnyHashable) {
        listeners.removeValue(forKey: unsubscriber)
    }
    
    private func notifyFailure(error: PError) {
        let result = Result<Void, PError>.failure(error)
        listeners.forEach({ listener in
            DispatchQueue.main.async{ listener.value(result) }
        })
    }
    
    private func notifySuccess() {
        let result: Result<Void, PError> = Result.success
        listeners.forEach({ listener in
            DispatchQueue.main.async{ listener.value(result) }
        })
    }
    
    //===================================================================
    
}
