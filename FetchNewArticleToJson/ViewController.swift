//
//  ViewController.swift
//  FetchNewArticleToJson
//
//  Created by Jonathan Duss on 27.08.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    

    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let articles = self.fetchArticles()
        let json = self.convertToJson(articles: articles)
        
        self.textView.string = json ?? "oups"
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    private func getFeedPO() -> [RssPlistFeed] {
        let decoder = PropertyListDecoder()
        let sitesPlistPath = Bundle.main.url(forResource: "RSSFeeds", withExtension: "plist")!
        do {
            let sitesPlist = try Data(contentsOf: sitesPlistPath)
            let sites = try decoder.decode([RssPlistFeed].self, from: sitesPlist)
            return sites
        }
        catch {
            return []
        }
    }
    
    private func convertToJson(articles: [RssArticlePO]) -> String? {
        let encoder = JSONEncoder()
    
        do {
            let json = try encoder.encode(articles)
            return String(data: json, encoding: String.Encoding.utf8)
        }
        catch {}
        return nil
    }
    
    private func fetchArticles() -> [RssArticlePO] {
        var fetchedArticles: [RssArticlePO] = []
        
        DispatchQueue(label: "fetchArticles").async {
            let feeds = self.getFeedPO()
            for feed in feeds {
                let articles = self.fetchArticle(of: feed)
                fetchedArticles = articles
                print("downloaded articles of \(feed.name)")
            }
        }
        return fetchedArticles
    }
    
    private func fetchArticle(of feed:RssPlistFeed) -> [RssArticlePO] {
        
        let client = RSSClient()
        let semaphore = DispatchSemaphore(value: 1)
        var articles: [RssArticlePO] = []

        DispatchQueue.main.sync {
            
            client.fetch(feed: feed, completion: { result in
                switch result {
                case .success(let fetchedArticles):
                    articles = fetchedArticles
                default: break
                }
                semaphore.signal()
            })
        }
        semaphore.wait()
        return articles
    }
    
}

