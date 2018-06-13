//
//  RssArticlesByProviderRequest.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.06.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import CoreData

class RssArticlesByProviderRequest {

    func create(withProvider provider: RssFeed) -> NSFetchRequest<RssArticle> {
        let request: NSFetchRequest<RssArticle> = RssArticlesRequest().create()
        request.predicate = NSPredicate(format: RssArticle.feedPropertyName + " == %@", provider)
        request.sortDescriptors = [NSSortDescriptor(key: RssArticle.datePropertyName, ascending: false)]
        return request
    }
    
}
