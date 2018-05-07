//
//  ArticlesListVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import CoreData
import JDSideMenu

class ArticlesListVC: MainViewControllerBase {
    
    @IBOutlet weak var tableview: UITableView!
    
    private var rssManager: RSSManager = Inject.component(RSSManager.self)
    fileprivate var articles: [RssArticle] = []
    
    var fetchResultController: NSFetchedResultsController<RssArticle>! = nil

    private var articleDetailsView: ArticleViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.setupFetchRequest()
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.register(UINib.init(nibName: String(describing: ArticleListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ArticleListCell.self))
        
//        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 100
        
        self.articleDetailsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticleViewController.self)) as! ArticleViewController
        
        rssManager.updateFeeds()
    }
    
    private func setupFetchRequest() {
        let request: NSFetchRequest<RssArticle> = RssArticle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: RssArticle.datePropertyName, ascending: false)]
        self.fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchResultController.delegate = self
        try? self.fetchResultController.performFetch()
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
    
    func showArticles(of: RssFeed) {
        
    }
    
    func showAllArticles() {
        
    }
    
    func showArticlesOfMyFavoriteFeeds() {
        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.articleListVC = self
            super.prepare(for: segue, sender: sender)
        }
    }
     
    
    fileprivate func showArticle(_ article: RssArticle) {
        if let url = article.link {
            self.articleDetailsView.load(url: url, title: article.feed.name)
            self.show(articleDetailsView, sender: self)
        }
    }

}

extension ArticlesListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: String(describing: ArticleListCell.self)) as! ArticleListCell
        
        if let article = fetchResultController.fetchedObjects?[indexPath.row] {
            cell.configure(with: article)
        }
        
        return cell
    }
}

extension ArticlesListVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let article = fetchResultController.fetchedObjects?[indexPath.row] {
            self.showArticle(article)
        }
    }
    
}

extension ArticlesListVC: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableview.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableview.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableview.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableview.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            tableview.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            self.tableview.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
    
}
