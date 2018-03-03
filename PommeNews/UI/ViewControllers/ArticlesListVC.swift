//
//  ArticlesListVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class ArticlesListVC: UIViewController {
    
    @IBOutlet weak var tableview: UITableView!
    
    private var rssManager: RSSManager!
    fileprivate var articles: [RssArticle] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.register(UINib.init(nibName: String(describing: ArticleListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ArticleListCell.self))
        
//        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 100
        
        rssManager = Inject.component(RSSManager.self)
        rssManager.getArticles(completion: self.articlesUpdated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func articlesUpdated(result: Result<[RssArticle]>) {
        switch result {
        case .failure(let error):
            //TODO
            break
        case .success(let articles):
            self.articles = articles
            self.tableview.reloadData()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ArticlesListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: String(describing: ArticleListCell.self)) as! ArticleListCell
        
        cell.configure(with: articles[indexPath.row])
        
        return cell
    }
}

extension ArticlesListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
}
