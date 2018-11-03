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

class RSSManager {
    
    struct Notifications {
        static let RssSitesUpdated = "RssSitesUpdated"
    }
    
    private struct StorageKeys {
        static let sitesToShow = "sitesToShow"
    }
    
    private let rssClient: RSSClient
    
    private (set) var feeds: [RssFeed] = []
    
    private var lastUpdate = Date()
    private let context = CoreDataStack.shared.context
    
    private let classifier = ThemeClassifier()
    
    init(rssClient: RSSClient) {
        self.rssClient = rssClient
        
        //Init Themes
        try! ThemeLoader().loadThemes()
        
        //TODO: Remove newly unsupported themes
        
        //Configure classifier
        let supportedThemes = Request<Theme>().execute(context: CoreDataStack.shared.context)
        classifier.validThemes = supportedThemes.map({ArticleTheme(key: $0.key)})
        
        //Init feeds
        var allFeeds: [RssFeed] = []
        for feed in supportedFeeds {
            allFeeds += [insertFeedInCoreData(feed)]
        }
        self.feeds = allFeeds
        do {
            try CoreDataStack.shared.save()
        }
        catch {
            print("\(error)")
        }
    }
    
    
    //MARK: - LOCAL
    //===================================================================
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
    
    private func insertFeedInCoreData(_ feed: RssPlistFeed) -> RssFeed {
        
        var coreDataFeed: RssFeed!
        
        if let existingFeed = fetchFeedWith(id: feed.id) {
            coreDataFeed = existingFeed
        }
        else {
            let newFeed = NSEntityDescription.insertNewObject(forEntityName: "RssFeed", into: CoreDataStack.shared.context) as! RssFeed            
            coreDataFeed = newFeed
            coreDataFeed.favorite = true
            coreDataFeed.hidden = false
        }
        coreDataFeed.id = feed.id
        coreDataFeed.name = feed.name
        coreDataFeed.url = URL(string: feed.url)!
        
        return coreDataFeed
    }
    
    private func fetchFeedWith(id: String) -> RssFeed? {
        
        let request: NSFetchRequest<RssFeed> = RssFeed.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: RssFeed.namePropertyName, ascending: true)]
        request.predicate = NSPredicate(format: "\(RssFeed.idPropertyName) == %@", id)
        
        //Add fetch in CoreDataStack
        do {
            let entitiesFetchResult = try context?.fetch(request)
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
    
    //MARK: - ONLINE
    //===================================================================
    
    ///Get the articles from all the feeds
    func updateFeeds(completion: ((Result<Void>) -> ())? = nil) {
        
        DispatchQueue(label: "FeedUpdate").async {
            
            let group = DispatchGroup()
            
            var error: PError? = nil
            //            var singleError = true
            
            for feed in self.feeds {
                group.enter()
                
                self.update(feed: feed, completion: { result in
                    switch result {
                    case .success(_): break
                    case .failure(let failureError):
                        if error != nil {
                            //                            singleError = false
                        }
                        else {
                            error = failureError
                        }
                    }
                    
                    group.leave()
                })
                
            }
            
            let timeout = group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(10))
            
            try? CoreDataStack.shared.save()
            
            if timeout ==  DispatchTimeoutResult.timedOut {
                //TODO: show error
            }
            else if let error = error  {
                completion?(.failure(error))
            }
            else {
                completion?(Result.success(()))
            }
        }
    }
    
    ///Get the new articles for the specified feed
    func update(feed: RssFeed, completion: ((Result<Void>) -> ())?) {
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
                completion?(.failure(error))
            }
        })
    }
    
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
        request.predicate = NSPredicate(format: "\(RssArticle.summaryPropertyName) == %@", article.summary)
        
        do {
            return try CoreDataStack.shared.context.count(for: request) != 0
        } catch {
            //TODO
            return false
        }
    }
    
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
    
    
}
