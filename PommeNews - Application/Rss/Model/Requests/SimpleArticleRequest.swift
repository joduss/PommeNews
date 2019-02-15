//
//  SimpleArticleRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 25.10.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class ArticleRequest: Request<RssArticle> {
    
    private var feedFilterPredicate: NSPredicate?
    private var showHiddenPredicate: NSPredicate?
    private var favoriteOnlyPredicate: NSPredicate?
    private var themePredicate: NSPredicate?
    
    init(favoriteOnly: Bool = false, showHidden: Bool = false, showOnlyFeed feed: RssFeed? = nil) {
        super.init(sortOrder: .Descending, sortKey: #keyPath(RssArticle.date))
        
        if let feed = feed {
            self.filter(fromFeed: feed)
        }
        
        self.filter(showHidden: showHidden)
        self.filter(showOnlyFavorite: favoriteOnly)
    }
    
    func filter(themes: [Theme]) {
        
        if let themePredicate = self.themePredicate {
            self.remove(predicate: themePredicate)
            self.themePredicate = nil
        }
        
        guard themes.count > 0 else {
            return
        }
        
        var themesPredicates: [NSPredicate] = []
        
        for theme in themes {
            themesPredicates.append(NSPredicate(format: "ANY themes == %@", theme))
        }
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: themesPredicates)
        self.and(compoundPredicate)
        self.themePredicate = compoundPredicate
    }
    
    func filter(fromFeed feed: RssFeed?) {
        if let feedFilterPredicate = self.feedFilterPredicate {
            self.remove(predicate: feedFilterPredicate)
            self.feedFilterPredicate = nil
        }
        
        guard let feed = feed else { return }
        
        let predicate = NSPredicate(format: #keyPath(RssArticle.feed) + " == %@", feed)
        self.and(predicate)
        self.feedFilterPredicate = predicate
        
    }
    
    func filter(showOnlyFavorite: Bool) {
        if let favoriteOnlyPredicate = self.favoriteOnlyPredicate {
            self.remove(predicate: favoriteOnlyPredicate)
            self.favoriteOnlyPredicate = nil
        }
        
        guard showOnlyFavorite == true else { return }
        let predicate = NSPredicate(format: #keyPath(RssArticle.feed) + "." + #keyPath(RssFeed.favorite) + " == %@", NSNumber(value: true))
        self.and(predicate)
        self.favoriteOnlyPredicate = predicate
    }
    
    func filter(showHidden: Bool) {
        if let showHiddenPredicate = self.showHiddenPredicate {
            self.remove(predicate: showHiddenPredicate)
            self.showHiddenPredicate = nil
        }
        
        guard showHidden == false else { return }
        
        let predicate = NSPredicate(format: #keyPath(RssArticle.feed) + "." + #keyPath(RssFeed.hidden) + " == %@", NSNumber(value: false))
        self.and(predicate)
        self.showHiddenPredicate = predicate        
    }
    
}



