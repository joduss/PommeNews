//
//  RSSFeed.swift
//  PommeNews
//
//  Created by Jonathan Duss on 31.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit

enum RSSFeedType {
    case atom(FeedKit.AtomFeed)
    case rss(FeedKit.RSSFeed)
    case json(FeedKit.JSONFeed)
}
