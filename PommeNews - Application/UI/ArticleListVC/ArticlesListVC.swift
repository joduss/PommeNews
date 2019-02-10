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
import GoogleMobileAds

class ArticlesListVC: ContentViewController {
    
    private static let CellHeight: CGFloat = 102
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    private var rssManager: RSSManager = Inject.component(RSSManager.self)

    private var fetchResultController: NSFetchedResultsController<RssArticle>! = nil
    private var desiredRequest: NSFetchRequest<RssArticle>!
    private var request: ArticleRequest?
    
    fileprivate var articles: [RssArticle] = []
    private let filtersPreferences = ThemeFiltersPreferences()

    private var articleDetailsView: ArticleViewController!
    
    private var bannerView: BannerView?
    
    //MARK: Life Cycle
    //==================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup TableView
        tableview.delegate = self
        tableview.dataSource = self
        tableview.estimatedRowHeight = ArticlesListVC.CellHeight
        tableview.register(UINib.init(nibName: String(describing: ArticleListCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ArticleListCell.self))
        
        tableview.refreshControl = UIRefreshControl()
        tableview.refreshControl?.addTarget(self, action: #selector(updateFeeds), for: .valueChanged)
        
        //Preload the ArticleDetailsView
        self.articleDetailsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticleViewController.self)) as? ArticleViewController
        
        //Request a Feeds Update
        self.updateFeeds()
        
        //AdBannerView initialisation
        self.bannerView = BannerView(on: self, adId: PommeNewsConfig.AdUnitBanner)
        
        //Lister to filter change
        filtersPreferences.onChange = { [unowned self] in
            self.filtersChanged()
        }
        filtersChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rssManager.feedsUpdater.subscribeToArticlesUpdate(subscriber: self, onPublish: articlesUpdated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        rssManager.feedsUpdater.unsubscribeFromArticlesupdate(self)
    }

    //MARK: - Data Handling
    //==================================================================
    
    @objc private func updateFeeds() {
        tableview.refreshControl?.beginRefreshing()
        rssManager.feedsUpdater.updateAllFeeds()
    }
    
    private func articlesUpdated(result: Result<Void>) {
        tableview.refreshControl?.endRefreshing()
    }
    
    private func filtersChanged() {
        self.filtersByThemes()
        
        //Update the filter buttons status
        
    }

    
    //MARK: - Fetch Request Configuration
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
    
    private func filtersByThemes() {
        let filteringThemes = filtersPreferences.filteringThemes
        self.request?.filter(themes: filteringThemes)
        self.request?.update()
        try! self.fetchResultController.performFetch()
    }
    
    //MARK: - Navigation
    //==================================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewController {
            menuVC.articleListVC = self
            super.prepare(for: segue, sender: sender)
        }
//        else if let filterVC = segue.destination.childViewControllers.first as? FiltersVC {
//            filterVC.onSave = { selectedTheme in
//                self.filtersByThemes
//            }
//        }
    }
    
    fileprivate func showArticle(_ article: RssArticle) {
        if let url = article.link {
            self.articleDetailsView.load(url: url, title: article.feed.name)
            self.show(articleDetailsView, sender: self)
        }
    }
    
    //MARK: - Actions
    //==================================================================
    
    @IBAction func filterButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: String(describing: FiltersVC.self), sender: self)
    }
    
}

//MARK: - Table View Delegate and Data Source
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

//MARK: - Fetch Results Controller Delegate
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
