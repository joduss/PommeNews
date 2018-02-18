//
//  RssArticle.swift
//  PommeNews
//
//  Created by Jonathan Duss on 14.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation


struct RssArticle {
    let title: String
    let summary: String
    
    let feed: RSSFeed
    
    let imageURL: URL?
    let date: Date
    let link: URL?
    
    let creator: String?
}
