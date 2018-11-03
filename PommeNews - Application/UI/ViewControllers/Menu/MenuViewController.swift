//
//  MenuViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Enums for data display order
//==================================================================

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
    
    static func sectionOf(tableSection: MenuTableSection) -> Int {
        switch tableSection {
        case .you: return 0
        case .providers: return 1
        default: return 2
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
//        case (0,1):
//            self = .thematicNews
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
        case 0: return 1
        case 1: return 1 + numberOfProviders
        case 2: return 1
        default: return 0
        }
    }
    
    static fileprivate func convertFetchIndexPathToTableIndexPath(_ indexPath: IndexPath?) -> IndexPath? {
        guard let indexPath = indexPath else {
            return nil
        }
        return IndexPath(row: indexPath.row + 1, section: MenuTableSection.sectionOf(tableSection: .providers))
    }
    
    static fileprivate func convertTableIndexPathToFetchIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row - 1, section: 0)
    }
}

//MARK: - MenuViewController
//==================================================================

class MenuViewController: UIViewController {
    
    @IBOutlet private weak var tableViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private let manager: RSSManager = Inject.component(RSSManager.self)
    
    private var fetchResultController: NSFetchedResultsController<RssFeed>!
    var articleListVC: ArticlesListVC!
    
    
    //MARK: Life Cycle
    //======================================================================
    
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
        
        self.initializeFetchResultControllerForFeeds()
        self.showDefaultSelection()
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
    
    //MARK: Configuration
    //======================================================================
    
    private func showDefaultSelection() {
        let newsVC = Scene.articlesListViewController
        let request = ArticleRequest(favoriteOnly: true)
        newsVC.setupWith(request: request)
        let vc = UINavigationController(rootViewController: newsVC)
        self.sideMenuController?.contentViewController = vc
    }
    
    ///Create the FetchResultsController
    ///To get the feeds to show in the menu
    private func initializeFetchResultControllerForFeeds() {
        
        let request = RssFeedRequest().showHidden(false).create()
        fetchResultController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: CoreDataStack.shared.context,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        fetchResultController.delegate = self
        try? fetchResultController.performFetch()
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }
    
}


//MARK: - Table View Delegate
//======================================================================

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
            newsVC.setupWith(request: ArticleRequest(favoriteOnly: true))
            vc = UINavigationController(rootViewController: newsVC)
            break
            
        case .thematicNews:
            break
        case .settings:
            vc = Scene.settingsViewController
            break
            
        case .allProviders:
            let newsVC = Scene.articlesListViewController
            newsVC.setupWith(request: ArticleRequest(favoriteOnly: false))
            vc = UINavigationController(rootViewController: newsVC)
            break
            
        case .aProvider:
            if let provider = fetchResultController.fetchedObjects?[indexPath.row - 1] {
                let newsVC = Scene.articlesListViewController
                let request = ArticleRequest(favoriteOnly: false, showOnlyFeed: provider)
                newsVC.setupWith(request: request)
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
    
        self.configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    fileprivate func configure(cell: MenuCell, at indexPath: IndexPath) {
        
        switch (MenuTableRowType(indexPath)) {
        case .yourNews:
            cell.setup(with: "menu.my_news".localized, image: #imageLiteral(resourceName: "myNews"))
        case .thematicNews:
            cell.setup(with: "menu.thematic_news".localized, image: #imageLiteral(resourceName: "theme-icon"))
            break
        case .settings:
            cell.setup(with: "menu.settings".localized, image: #imageLiteral(resourceName: "settings"))
        case .allProviders:
            cell.setup(with: "menu.all_sources".localized, image: #imageLiteral(resourceName: "rss"))
        case .aProvider:
            let indexPathInFetchResults = MenuTableRowType.convertTableIndexPathToFetchIndexPath(indexPath)
            cell.setup(with: fetchResultController.fetchedObjects![indexPathInFetchResults.row], numberUnreadArticles: 10)
        }
    }
    
}

//MARK: - Fetch Results Controller Delegate
//==================================================================
extension MenuViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: .automatic)
        case .insert:
            self.tableView.insertSections([sectionIndex], with: .automatic)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let indexPathConverted = MenuTableRowType.convertFetchIndexPathToTableIndexPath(indexPath)
        let newIndexPathConverted = MenuTableRowType.convertFetchIndexPathToTableIndexPath(newIndexPath)
        
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPathConverted!], with: .automatic)
        case .delete:
            self.tableView.deleteRows(at: [indexPathConverted!], with: .automatic)
        case .move:
            self.tableView.moveRow(at: indexPathConverted!, to: newIndexPathConverted!)
        case .update:
            if let cell = tableView.cellForRow(at: indexPathConverted!) as? MenuCell {
                self.configure(cell: cell, at: indexPathConverted!)
            }
        }
    }
    
    
}
