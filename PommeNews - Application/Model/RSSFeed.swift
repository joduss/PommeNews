//
//  RSSFeedSite.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

///The highest abstraction level of an RSSFeed: name + url
extension RssFeed: EntityName {
    
    //MARK: - Static constants related to the model
    //==================================================
    public static var entityName: String {
        return String(describing: RssFeed.self)
    }
    
    static var namePropertyName: String {
        return "name"
    }
    
    static var idPropertyName: String {
        return "id"
    }
    
    static var urlPropertyName: String {
        return "url"
    }
    
    static var articlePropertyName: String {
        return "articles"
    }
    
    static var favoritePropertyName: String {
        return "favorite"
    }
    
    static var hiddenPropertyName: String {
        return "hidden"
    }

    
    //MARK: - Helpers
    //==================================================
    
    var logo: UIImage? {
        return UIImage(named: id)
    }

}
