//
//  DevCenterHomeVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 05.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit
import ArticleClassifierCore

class DevCenterHomeVC: UITableViewController {
    
    private var articles: [RssArticle] = []
    private var selectedArticle: RssArticle?
    private var similarities: [(Double, RssArticle)]? = nil

    private var tfIdf: TfIdf!
    private let nf = NumberFormatter()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadArticles()
        self.tableView.reloadData()
        nf.maximumFractionDigits = 6
        nf.minimumIntegerDigits = 1
    }
    
    private func loadArticles() {
        articles = ArticleRequest().execute(context: CoreDataStack.shared.context)
        tfIdf = TfIdf(texts: articles.map({$0.summary?.truncate(length: 400) ?? ""}))
        tfIdf.importantTerms = ["iphone", "android", "ios", "microsoft", "apple", "samsung", "google",
        "ipad", "mac", "imac", "macbook", "macos", "windows", "watch", "pay", "netflix", "oneplus", "twitter", "huawei", "xaomi", "mozilla", "chrome", "pixel", "htc"]
        
        guard let selectedArticle = self.selectedArticle else {
            return
        }
        
        var sorted: [(Double, RssArticle)] = []
        
        let tfIdfSelected = tfIdf.tfIdfVector(text: selectedArticle.title + (selectedArticle.summary?.truncate(length: 400) ?? ""))
        
        for article in articles {
            var sim = 0.0
            if (article.date.timeIntervalSinceReferenceDate - selectedArticle.date.timeIntervalSinceReferenceDate).magnitude < 24 * 3600 {
                let tfIdfArticle = tfIdf.tfIdfVector(text: selectedArticle.title + (article.summary?.truncate(length: 400) ?? ""))
                sim = CosineSimilarity.computer(vector1: tfIdfSelected, vector2: tfIdfArticle)
            }
            sorted.append((sim, article))
        }
        
        similarities = sorted.sorted(by: {$0.0 > $1.0})
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let titleLabel = cell.viewWithTag(1000) as! UILabel
        let summaryLabel = cell.viewWithTag(1001) as! UILabel
        let tfIdfLabel = cell.viewWithTag(1002) as! UILabel
        
        

        
        if let selectedArticle = self.selectedArticle, let similarities = self.similarities {
            let simArticle = similarities[indexPath.row]
            let article = simArticle.1
            titleLabel.text = article.title
            summaryLabel.text = article.summary
            tfIdfLabel.text = nf.string(from: NSNumber(value: simArticle.0))
        }
        else {
            let article = articles[indexPath.row]
            titleLabel.text = article.title
            summaryLabel.text = article.summary
            tfIdfLabel.text = nil
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let similarities = self.similarities {
            selectedArticle = similarities[indexPath.row].1
        }
        else {
            selectedArticle = articles[indexPath.row]
        }
        self.loadArticles()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(300), execute: {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
        })
    }
    
    
}
