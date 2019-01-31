//
//  RSSClient.swift
//  PommeNews
//
//  Created by Jonathan Duss on 29.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit

public class RSSClient {
    
    let session = URLSession(configuration: .default)
    
    private var loading = false
    
    func fetch(feed: RssPlistFeed, completion:@escaping (Result<[RssArticlePO]>) -> ()) {
        
        let parser = FeedParser(URL: URL(string: feed.url)!)
        
        parser?.parseAsync(result: { result in
            
            switch result {
            case .atom(_):
                completion(Result.failure(PError.unsupported))
                assertionFailure("Atom not supported")
                
            case .rss(let rssFeed):
                self.process(rssFeed: rssFeed, completion: completion)
                
                break
            case .json(_):
                completion(Result.failure(PError.unsupported))
                assertionFailure("Json not supported")
                break
            case .failure(let error):
                completion(Result.failure(PError.FeedFetchingError(error)))
            }
        })
    }
    
    
    private func process(rssFeed: RSSFeed, completion:@escaping (Result<[RssArticlePO]>) -> ()) {
        guard let entries = rssFeed.items else {
            completion(Result.success([]))
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
                                       imageUrl: URL(string: imagePath ?? ""),
                                       date: date,
                                       link: URL(string: link),
                                       creator: entry.author ?? "?")
            articles.append(article)
        }
        
        completion(.success(articles))
    }

}
