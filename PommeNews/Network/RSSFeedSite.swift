//
//  RSSFeedSite.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation

///The highest abstraction level of an RSSFeed: name + url
struct RSSFeedSite: Hashable, Codable {
    
    let name: String
    let url: String
    let id: String
//    let show: Bool
//
//    init(name: String, url: URL, id: String, show: Bool = true) {
//        self.name = name
//        self.url = url
//        self.id = id
//        self.show = show
//    }
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static func ==(lhs: RSSFeedSite, rhs: RSSFeedSite) -> Bool {
        return lhs.id == rhs.id
    }
}
