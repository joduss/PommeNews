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
    
    private (set) var feeds: [RssFeed] = []
    
    private let classifier = ThemeClassifier()

    
    private var lastUpdate = Date()
    private let context = CoreDataStack.shared.context
    
    public var feedsUpdater: FeedsUpdater! = nil
    
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
        
        self.feedsUpdater = FeedsUpdater(rssManager: self, classifier: self.classifier, rssClient: self.rssClient)
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
