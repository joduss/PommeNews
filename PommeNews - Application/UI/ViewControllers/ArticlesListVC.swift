//
//  ArticlesListVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 01.02.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import CoreData
import SideMenu

class ArticlesListVC: ContentViewController {
    
    private static let CellHeight: CGFloat = 102
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    private var rssManager: RSSManager = Inject.component(RSSManager.self)
    fileprivate var articles: [RssArticle] = []
    
    private var fetchResultController: NSFetchedResultsController<RssArticle>! = nil
    private var desiredRequest: NSFetchRequest<RssArticle>!
    private var request: ArticleRequest?

    private var articleDetailsView: ArticleViewController!
    
    private var activeFilters: [Theme] = []
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: String(describing: FiltersVC.self), sender: self)
    }
    
    //MARK: Life Cycle
    //==================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.estimatedRowHeight = ArticlesListVC.CellHeight
        tableview.register(UINib.init(nibName: String(describing: ArticleListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ArticleListCell.self))
        self.articleDetailsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticleViewController.self)) as? ArticleViewController
        
        rssManager.updateFeeds()
    }
    
    //MARK: Fetch Request Configuration
    //==================================================================
    
    private func executeArticlesFetchRequest() {
        guard let request = self.request?.fetchRequest() else {
            return
        }
    
        self.fetchResultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchResultController.delegate = self
        try? self.fetchResultController.performFetch()
    }
    
    func setupWith(request: ArticleRequest) {
        self.request = request
        self.executeArticlesFetchRequest()
    }
    
    //MARK: Nav
    //==================================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.articleListVC = self
            super.prepare(for: segue, sender: sender)
        }
        else if let filterVC = segue.destination.childViewControllers.first as? FiltersVC {
            filterVC.activeFilters = self.activeFilters
            filterVC.onSave = { selectedTheme in
                self.activeFilters = selectedTheme
                self.request?.filter(themes: selectedTheme)
                self.request?.update()
                try! self.fetchResultController.performFetch()
                self.tableview.reloadData()
            }
        }
    }
    
    
    fileprivate func showArticle(_ article: RssArticle) {
        if let url = article.link {
            self.articleDetailsView.load(url: url, title: article.feed.name)
            self.show(articleDetailsView, sender: self)
        }
    }
    
}

//MARK: Table View Delegate and Data Source
//==================================================================

extension ArticlesListVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController == nil ? 0 : 1
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
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let article = fetchResultController.fetchedObjects?[indexPath.row] {
            self.showArticle(article)
        }
    }
    
}

//MARK: Fetch Results Controller Delegate
//==================================================================

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
