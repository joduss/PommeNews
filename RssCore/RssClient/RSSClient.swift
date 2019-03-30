//
//  RSSClient.swift
//  PommeNews
//
//  Created by Jonathan Duss on 29.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit
import ZaJoLibrary


open class RSSClient {
    
    let session = URLSession(configuration: .default)
    
    private var loading = false
    
    public init() { }
    
    open func fetch(feed: RssPlistFeed, completion:@escaping (Swift.Result<[RssArticlePO], PError>) -> ()) {
        
        let parser = FeedParser(URL: URL(string: feed.url)!)
                
        parser?.parseAsync(result: { result in
            
            switch result {
            case .atom(_):
                completion(.failure(PError.unsupported))
                assertionFailure("Atom not supported")
                
            case .rss(let rssFeed):
                self.process(rssFeed: rssFeed, completion: completion)
                
                break
            case .json(_):
                completion(.failure(PError.unsupported))
                assertionFailure("Json not supported")
                break
            case .failure(let error):
                completion(.failure(PError.FetchingError(error)))
            }
        })
    }
    
    
    private func process(rssFeed: RSSFeed, completion:@escaping (Swift.Result<[RssArticlePO], PError>) -> ()) {
        guard let entries = rssFeed.items else {
            completion(.success([]))
            return
        }
        
        var articles: [RssArticlePO] = []
        
        for entry in entries {
            
            guard let title = entry.title,
                let summary = entry.description,
                let date = entry.pubDate,
                let link = entry.link
                else {
                    continue
            }
             
            var imagePath = entry.media?.mediaThumbnails?.first?.attributes?.url
            
            if imagePath == nil && entry.enclosure?.attributes?.type?.contains("image") ?? false {
                imagePath = entry.enclosure?.attributes?.url
            }
            
            let article = RssArticlePO(titleHtml: title,
                                       summaryHtml: summary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                       date: date,
                                       imageUrl: URL(string: imagePath ?? ""),
                                       link: URL(string: link),
                                       creator: entry.author ?? "?")
            articles.append(article)
        }
        
        completion(.success(articles))
    }

}
