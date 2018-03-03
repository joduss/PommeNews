//
//  RSSManager.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Foundation
import FeedKit

class RSSManager {
    
    struct Notifications {
        static let RssSitesUpdated = "RssSitesUpdated"
    }
    
    private struct StorageKeys {
        static let sitesToShow = "sitesToShow"
    }
    
    private let rssClient: RSSClient
    
    init(rssClient: RSSClient) {
        self.rssClient = rssClient
    }
    
    func getAllRssSites() -> [RSSFeedSite] {
        let decoder = PropertyListDecoder()
        let sitesPlistPath = Bundle.main.url(forResource: "RSSFeeds", withExtension: "plist")!
        do {
            let sitesPlist = try Data(contentsOf: sitesPlistPath)
            let sites = try decoder.decode([RSSFeedSite].self, from: sitesPlist)
            return sites
        }
        catch {
            return []
        }
    }
    
    func getRssSitesToShow() -> [RSSFeedSite] {
        
        guard let ids = UserDefaults.standard.array(forKey: StorageKeys.sitesToShow) as? [String] else {
            let defaultSitesIds = getAllRssSites().map({$0.id})
            UserDefaults.standard.setValue(defaultSitesIds, forKey: StorageKeys.sitesToShow)
            return getAllRssSites()
        }

        return getAllRssSites().filter({ids.contains($0.id)})
    }

    func showSite(_ site: RSSFeedSite) {
        guard var ids = UserDefaults.standard.array(forKey: StorageKeys.sitesToShow) as? [String],
            ids.contains(site.id) == false else {
                return
        }
        ids.append(site.id)
        UserDefaults.standard.setValue(ids, forKey: StorageKeys.sitesToShow)
    }
    
    func hideSite(_ site: RSSFeedSite) {
        guard var ids = UserDefaults.standard.array(forKey: StorageKeys.sitesToShow) as? [String] else {
                return
        }
        guard let idxToRemove = ids.index(of: site.id) else {
            return
        }
        ids.remove(at: idxToRemove)
        UserDefaults.standard.setValue(ids, forKey: StorageKeys.sitesToShow)
    }
    
    
    func getArticles(completion: @escaping (Result<[RssArticle]>) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
        
            var articles: [RssArticle] = []
            
            let group = DispatchGroup()
            
            for site in self.getRssSitesToShow() {
                group.enter()
                self.rssClient.fetch(stream: site, completion: { result in
                    switch result {
                    case .failure(let error):
                        //todo
                        print(error)
                        break
                    case .success(let feed):
                        articles += feed
                        break
                    }
                    
                    //append
                    group.leave()
                })
            }
            
            //TODO
            _ = group.wait(timeout: DispatchTime.now() + DispatchTimeInterval.seconds(300)) //TODO)
            
            DispatchQueue.main.async {
                completion(Result.success(articles))
            }
        }
    }
    
    
}
