//
//  RssArticle.swift
//  PommeNews
//
//  Created by Jonathan Duss on 14.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import HTMLString

struct RssArticle {
    let titleHtml: String
    let summaryHtml: String
    
    let feed: RSSFeed
    
    let imageURL: URL?
    let date: Date
    let link: URL?
    
    let creator: String?
    let site: RSSFeedSite
    
    var summary: String {
        let summary = self.summaryHtml.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return summary.removingHTMLEntities
    }
    
    var title: String {
        let title = self.titleHtml.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return title.removingHTMLEntities
    }
    
    func extractImageUrlFromSummary() -> URL? {
        let regex = try! NSRegularExpression(pattern: "<img src=\\\"([:0-9a-zA-Z-_\\/.]+)\\\"", options: .anchorsMatchLines)
        
        guard let nsrangeOfFound = regex.firstMatch(in: self.summaryHtml,
                                                    options: .withoutAnchoringBounds,
                                                    range: NSRange(location: 0, length: self.summaryHtml.count))?.range(at: 1)
            else { return nil }
        
        guard let rangeOfFound = Range(nsrangeOfFound, in: self.summaryHtml) else { return nil }
        return URL(string: String(self.summaryHtml[rangeOfFound]))
    }
    
    var placeholderImage: URL? {
        switch feed {
        case .rss(let rssFeed):
            return URL(string: rssFeed.image?.url ?? "")
        case .atom(let atomFeed):
            return URL(string: atomFeed.logo ?? "")
        case .json(let jsonFeed):
            return URL(string: jsonFeed.icon ?? "")
        }
    }
}
