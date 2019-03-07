//
//  FakeRSSClient.swift
//  PommeNews
//
//  Created by Jonathan Duss on 16.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import ZaJoLibrary
import RssClient
import FeedKit

class MockRSSClient: RSSClient {
    
    override func fetch(feed: RssPlistFeed,  completion:@escaping (ZaJoLibrary.Result<[RssArticlePO], PError>) -> ()) {
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: feed.id, ofType: ".xml")!))
        
        let parser = FeedParser(data: data)
        
        parser?.parseAsync(result: { result in
            
            var articles: [RssArticlePO] = []
            
            switch result {
            case .atom(_):
                assertionFailure("Atom not supported")
                //                guard let entries = atomFeed.entries else { return }
                //
                //                var articles: [RssArticle] = []
                //
                //                for entry in entries {
                //
                //                    guard let title = entry.title,
                //                        let summary = entry.summary?.value,
                //                        let link = entry.links?.first,
                //                        let date = entry.published
                //                        else {
                //                            continue
                //                    }
                //
                //                    let article = RssArticle(title: title,
                //                                             summary: summary,
                //                                             feed: RSSFeed.atom(atomFeed),
                //                                             imageURL: URL(string: entry.media?.mediaThumbnails?.first?.attributes?.url ?? ""),
                //                                             date: date,
                //                                             link: URL(string: link.attributes?.href ?? ""),
                //                                             creator: entry.authors.first.name ?? "rssarticle.unknownAuthor".localized)
                //                    articles.append(article)
                //                }
                //                break
                
            case .rss(let rssFeed):
                guard let entries = rssFeed.items else { return }
                for entry in entries {
                    
                    guard let title = entry.title,
                        let summary = entry.description,
                        let date = entry.pubDate
                        else {
                            continue
                    }
                    
                    let article = RssArticlePO(titleHtml: title,
                                             summaryHtml: summary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                             date: date,
                                             imageUrl: URL(string: entry.media?.mediaThumbnails?.first?.attributes?.url),
                                             link: URL(string: entry.link),
                                             creator: entry.author
                                             )
                    
                    
                    articles.append(article)
                }
                completion(Result.success(articles))
                break
            case .json(_):
                assertionFailure("json not supported")
                break
            case .failure(let error):
                //completion(Result.failure(PError.SomeFeedFetchingError(error)))
                exit(1)
            }
            
            
        })
    }
    
    
    
    
}
