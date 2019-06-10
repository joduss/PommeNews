//
//  RssFeedsStore.swift
//  PommeNews
//
//  Created by Jonathan Duss on 25.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import Foundation
import RssClient
import ZaJoLibrary
import CoreData
import NSLoggerSwift
import NaturalLanguage

/// Manages the Rss feeds
/// For fetching, use RssFeedRequest.
class RssFeedStore: Hashable {
    
    private(set) var feeds: [RssFeed] = []
    private weak var rssManager: RSSManager!
    private let instanceId = UUID.init()
    
    public init(rssManager: RSSManager) {
        self.rssManager = rssManager
        
        //Init feeds
        var allFeeds: [RssFeed] = []
        for feed in supportedFeeds {
            allFeeds += [addPlistFeed(feed: feed)]
        }
        self.feeds = allFeeds
        do {
            try CoreDataStack.shared.save()
        }
        catch {
            print("\(error)")
        }
    }
    
    /// The list of feeds supported by default.
    var supportedFeeds: [RssPlistFeed] {
        let decoder = PropertyListDecoder()
        let sitesPlistPath = Bundle.main.url(forResource: "RSSFeeds", withExtension: "plist")!
        do {
            let sitesPlist = try Data(contentsOf: sitesPlistPath)
            let sites = try decoder.decode([RssPlistFeed].self, from: sitesPlist)
            return sites
        }
        catch {
            return []
        }
    }
    
    /// Add the feed coming from the configuration plist file if it is
    /// not already added.
    private func addPlistFeed(feed: RssPlistFeed) -> RssFeed {
        
        var coreDataFeed: RssFeed!
        
        if let existingFeed = self.feed(with: feed.id) {
            coreDataFeed = existingFeed
        }
        else {
            let newFeed = NSEntityDescription.insertNewObject(forEntityName: RssFeed.entityName, into: CoreDataStack.shared.context) as! RssFeed
            coreDataFeed = newFeed
            coreDataFeed.favorite = true
            coreDataFeed.hidden = false
            coreDataFeed.addedByUser = false
        }
        // Update if needed
        coreDataFeed.id = feed.id
        coreDataFeed.name = feed.name
        coreDataFeed.url = URL(string: feed.url)!
        coreDataFeed.language = feed.language
        
        return coreDataFeed
    }
    
    ///Returns the feed with the specified id
    private func feed(with id: String) -> RssFeed? {
        
        let request: NSFetchRequest<RssFeed> = RssFeed.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: RssFeed.namePropertyName, ascending: true)]
        request.predicate = NSPredicate(format: "\(RssFeed.idPropertyName) == %@", id)
        
        //Add fetch in CoreDataStack
        do {
            let entitiesFetchResult = try CoreDataStack.shared.context?.fetch(request)
            guard let entities = entitiesFetchResult else {
                return nil
            }
            
            if entities.count == 0 {
                return nil
            }
            else if entities.count == 1 {
                return entities.first!
            }
            else {
                throw PError.inconsistency("Entity should be UNIQUE")
            }
        } catch {
            return nil
        }
    }
    
    /// Remove the specified feed
    public func remove(feed: RssFeed) {
        CoreDataStack.shared.context.delete(feed)
    }
    
    // MARK: - User Feeds
    
    
    /// Allows the user to add a new feed. If a feed with the same url was already added,
    /// it will be ignored.
    ///
    /// - Parameters:
    ///   - name: The display name
    ///   - url: the url
    public func addNewUserFeed(name: String, url: URL) {
        
        if self.feed(with: url.absoluteString) == nil {
            let newFeed = NSEntityDescription.insertNewObject(forEntityName: RssFeed.entityName, into: CoreDataStack.shared.context) as! RssFeed
            newFeed.favorite = true
            newFeed.hidden = false
            newFeed.id = "\(url.absoluteString.hashValue)"
            newFeed.name = name
            newFeed.url = url
            newFeed.addedByUser = true
            
            try? CoreDataStack.shared.save()

            detectLanguage(feed: newFeed)
        }
        
        
    }
    
    private func detectLanguage(attempt: Int = 0, feed feedOnMainThread: RssFeed) {
        
        if attempt >= 2 {
            Logger.shared.log(Logger.Domain.app, .important, "Couldn't detect the language: fetching articles failed.")
        }
        
        CoreDataStack.shared.executeInNewQueueWith(object: feedOnMainThread) {
            feed in
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.rssManager.feedsUpdater.subscribeToArticlesUpdate(subscriber: self, onPublish: { _ in
                semaphore.signal()
            })
            self.rssManager.feedsUpdater.update(feeds: [feed])
            
            let waited = semaphore.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(30))
            
            guard waited != DispatchTimeoutResult.timedOut else {
                self.detectLanguage(attempt: 1, feed: feed)
                return
            }
            
            guard let article = feed.articles.first else {
                self.detectLanguage(attempt: 1, feed: feed)
                return
            }
            
            guard let languageCode = self.language(of: article) else {
                self.detectLanguage(attempt: 1, feed: feed)
                return
            }
            
            feed.language = languageCode
        }
    }
    
    /// Returns the language iso code.
    private func language(of article: RssArticle) -> String? {
        let text = article.summary ?? article.title
        
        guard let languageCode = NLLanguageRecognizer.dominantLanguage(for: text)?.rawValue else  {
            return nil
        }
        
        return languageCode
    }
    
    static func == (lhs: RssFeedStore, rhs: RssFeedStore) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(instanceId)
    }
}
