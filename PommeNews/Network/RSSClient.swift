//
//  RSSClient.swift
//  PommeNews
//
//  Created by Jonathan Duss on 29.01.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit


class RSSClient {
    
    let session = URLSession(configuration: .default)
    
    func fetch(stream: RSSFeedSite,  completion:@escaping (Result<[RssArticle]>) -> ()) {
        //        session.dataTask(with: stream.url, completionHandler: { data, response, error in
        //
        //            if let error = error {
        //                let perror = PError.HTTPErrorCode((error as NSError).code)
        //                completion(Result.failure(perror))
        //                return
        //            }
        //
        //            guard let data = data else {
        //                completion(Result.failure(PError.HTTPErrorInvalidFormat))
        //                return
        //            }
        //
        //            //process XML
        //
        //        })
        
        let parser = FeedParser(URL: URL(string: stream.url)!)
        parser?.parseAsync(result: { result in
            
            var articles: [RssArticle] = []

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
                        let creator = entry.author,
                        let date = entry.pubDate
                        else {
                            continue
                    }
                    
                    let article = RssArticle(titleHtml: title,
                                             summaryHtml: summary.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                                             feed: RSSFeed.rss(rssFeed),
                                             imageURL: URL(string: entry.media?.mediaThumbnails?.first?.attributes?.url),
                                             date: date,
                                             link: URL(string: entry.link),
                                             creator: creator)
                    articles.append(article)
                    completion(Result.success(articles))
                }
                break
            case .json(_):
                assertionFailure("Json not supported")
                break
            case .failure(let error):
                completion(Result.failure(PError.FeedFetchingError(error)))
            }
            
            
        })
    }
    
    
}
