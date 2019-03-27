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

class RssFeedStore {
    
    private(set) var feeds: [RssFeed] = []

    
    public init() {
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
        
        return coreDataFeed
    }
    
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
    public func addNewFeed(name: String, url: URL) {
        
        if self.feed(with: url.absoluteString) == nil {
            let newFeed = NSEntityDescription.insertNewObject(forEntityName: RssFeed.entityName, into: CoreDataStack.shared.context) as! RssFeed
            newFeed.favorite = true
            newFeed.hidden = false
            newFeed.id = url.absoluteString
            newFeed.name = name
            newFeed.url = url
            newFeed.addedByUser = true
        }
    }
    
    var userFeeds: [RssFeed] {
        return feeds.filter({ $0.addedByUser == true })
    }
    
}
