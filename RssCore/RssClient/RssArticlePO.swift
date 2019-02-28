//
//  RssClientArticle.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//


import Foundation
import HTMLString

///Simple common representation of an article. Makes usage later much easier.
public struct RssArticlePO: Codable {
    public let titleHtml: String
    public let summaryHtml: String
    
    
    public let imageUrl: URL?
    public let date: Date
    public let link: URL?
    
    public let creator: String?
    
    public init(titleHtml: String, summaryHtml: String, date: Date, imageUrl: URL?, link: URL?, creator: String?) {
        self.titleHtml = titleHtml
        self.summaryHtml = summaryHtml
        self.date = date
        self.imageUrl = imageUrl
        self.link = link
        self.creator = creator
    }
    
    
    public var summary: String {
        let summary = self.summaryHtml.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return summary.removingHTMLEntities
    }
    
    public var title: String {
        let title = self.titleHtml.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        return title.removingHTMLEntities
    }
    
    public func extractImageUrlFromSummary() -> URL? {
        let regex = try! NSRegularExpression(pattern: "<img src=\\\"([:0-9a-zA-Z-_\\/.]+)\\\"", options: .anchorsMatchLines)
        
        guard let nsrangeOfFound = regex.firstMatch(in: self.summaryHtml,
                                                    options: .withoutAnchoringBounds,
                                                    range: NSRange(location: 0, length: self.summaryHtml.count))?.range(at: 1)
            else { return nil }
        
        guard let rangeOfFound = Range(nsrangeOfFound, in: self.summaryHtml) else { return nil }
        return URL(string: String(self.summaryHtml[rangeOfFound]))
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
