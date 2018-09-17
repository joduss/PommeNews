//
//  RssArticle.swift
//  PommeNews
//
//  Created by Jonathan Duss on 14.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import HTMLString

extension RssArticle: EntityName {
    
    static var entityName: String {
        return String(describing: RssArticle.self)
    }
    
    static var creatorPropertyName: String {
        return "creator"
    }
    
    static var titlePropertyName: String {
        return "title"
    }
    
    static var summaryPropertyName: String {
        return "summary"
    }
    
    static var readPropertyName: String {
        return "read"
    }
    
    static var datePropertyName: String {
        return "date"
    }
    
    static var feedPropertyName: String {
        return "feed"
    }
    
}

extension RssArticle {
    
    var placeholderImage: URL? {
        //        switch feed {
        //        case .rss(let rssFeed):
        //            return URL(string: rssFeed.image?.url ?? "")
        //        case .atom(let atomFeed):
        //            return URL(string: atomFeed.logo ?? "")
        //        case .json(let jsonFeed):
        //            return URL(string: jsonFeed.icon ?? "")
        //        }
        return nil
    }
    
    
}

//extension RssArticle: Hashable, Equatable {
//    var hashValue: Int {
//        return self.title.hashValue * self.date.hashValue * self.site.id.hashValue
//    }
//
//    static func ==(left: RssArticle, right: RssArticle) -> Bool {
//        return left.hashValue == right.hashValue
//    }
//}
