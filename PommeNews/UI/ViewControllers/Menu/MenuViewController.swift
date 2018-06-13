//
//  MenuViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import CoreData

private enum MenuTableSection {
    case you
    case providers
    case settings
    
    init(_ section: Int) {
        switch section {
        case 0: self = .you
        case 1: self = .providers
        default: self = .settings
        }
    }
    
    static fileprivate func numberOfSections() -> Int {
        return 3
    }
}

private enum MenuTableRowType {
    case yourNews
    case thematicNews
    case settings
    case allProviders
    case aProvider
    
    init(_ indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            self = .yourNews
        case (0,1):
            self = .thematicNews
        case (2,0):
            self = .settings
        case (1,0):
            self = .allProviders
        default:
            self = .aProvider
        }
    }
    
    static fileprivate func numberOfRows(in section: Int, numberOfProviders: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 1 + numberOfProviders
        case 2: return 1
        default: return 0
        }
    }
}


class MenuViewController: UIViewController {
    
    
    var fetchResultController: NSFetchedResultsController<RssFeed>!
    
    @IBOutlet weak var tableViewWidthConstraint: NSLayoutConstraint!
    
    let manager: RSSManager = Inject.component(RSSManager.self)
    
    var articleListVC: ArticlesListVC!
    
    /*
     
     Header with logo
     
     
     first cell: your news
     second cell: settings 
     
     //second group: News providers
     // all
     // each provider
     
     
     */
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let theClass = String(describing: MenuCell.self)
        self.tableView.register(UINib(nibName: theClass, bundle: nil), forCellReuseIdentifier: theClass)
        
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.frame = CGRect(x: 0, y: 0, width: 250, height: 75)
        
        self.tableView.tableHeaderView = view
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let request = NSFetchRequest<RssFeed>(entityName: RssFeed.entityName)
        request.sortDescriptors = [NSSortDescriptor.init(key: RssFeed.namePropertyName, ascending: true)]
        fetchResultController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: CoreDataStack.shared.context,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        try? fetchResultController.performFetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //        self.tableViewWidthConstraint.constant = self.view.frame.width * SideMenuConfiguration.menuRelativeWidth
    }
    
}



extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var vc: UIViewController!
        
        switch MenuTableRowType(indexPath) {
        case .yourNews:
            let newsVC = Scene.articlesListViewController
            newsVC.request = RssFavoriteArticlesRequest().create()
            vc = UINavigationController(rootViewController: newsVC)
            break
            
        case .thematicNews:
            break
        case .settings:
            vc = Scene.settingsViewController
            break
            
        case .allProviders:
            let newsVC = Scene.articlesListViewController
            newsVC.request = RssArticlesRequest().create()
            newsVC.request.sortDescriptors = [NSSortDescriptor(key: RssArticle.datePropertyName, ascending: true)]
            vc = UINavigationController(rootViewController: newsVC)
            break
            
        case .aProvider:
            if let provider = fetchResultController.fetchedObjects?[indexPath.row - 1] {
                let newsVC = Scene.articlesListViewController
                newsVC.request = RssArticlesByProviderRequest().create(withProvider: provider)
                vc = UINavigationController(rootViewController: newsVC)
            }
            break
        }
        
        self.sideMenuController?.contentViewController = vc
        self.sideMenuController?.hideMenu()
        
    }
    
}


extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return MenuTableSection.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfProviders = fetchResultController.fetchedObjects?.count ?? 0
        return MenuTableRowType.numberOfRows(in: section, numberOfProviders: numberOfProviders)
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch MenuTableSection(section) {
        case .you: return nil
        case .providers: return "menu.sources".localized
        case .settings: return "menu.settings".localized
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuCell.self)) as! MenuCell
        
        switch (MenuTableRowType(indexPath)) {
        case .yourNews:
            cell.setup(with: "menu.my_news".localized, image: #imageLiteral(resourceName: "myNews"))
        case .thematicNews:
            cell.setup(with: "menu.thematic_news".localized, image: nil)
            break
        case .settings:
            cell.setup(with: "menu.settings".localized, image: #imageLiteral(resourceName: "settings"))
        case .allProviders:
            cell.setup(with: "menu.all_sources".localized, image: #imageLiteral(resourceName: "rss"))
        case .aProvider:
            cell.setup(with: fetchResultController.fetchedObjects![indexPath.row - 1], numberUnreadArticles: 10)
        }
        
        return cell
    }
    
    
    
}
