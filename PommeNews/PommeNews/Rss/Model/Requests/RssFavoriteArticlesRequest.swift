//
//  RssFavoriteArticleRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 07.06.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class RssFavoriteArticlesRequest {

    func create() -> NSFetchRequest<RssArticle> {
        let request: NSFetchRequest<RssArticle> = RssArticlesRequest().create()
        request.predicate = NSPredicate(format: "feed." + #keyPath(RssFeed.favorite) + " == %@", NSNumber(value: true))
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(RssArticle.date), ascending: false)]
        return request
    }
    
}
