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
    
    init(_ section: Int) {
        self = (section == 0) ? .you : .providers
    }
}

private enum MenuTableRowType {
    case yourNews
    case settings
    case allProviders
    case aProvider
    
    init(_ indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            self = .yourNews
        case (0,1):
            self = .settings
        case (1,0):
            self = .allProviders
        default:
            self = .aProvider
        }
    }
}

class MenuViewController: MenuViewControllerBase {
    
    
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
        self.tableViewWidthConstraint.constant = self.view.frame.width * SideMenuConfiguration.menuRelativeWidth
    }
    
}



extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = UIColor.lightGray
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        switch MenuTableRowType(indexPath) {
        case .yourNews:
            break
        case .settings:
            break
        case .allProviders:
            break
        case .aProvider:
            break
        }
        
    }
    
}


extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if MenuTableSection(section) == .you {
            return 2
        }
        return fetchResultController.fetchedObjects?.count ?? 0 + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if MenuTableSection(section) == .providers {
            return "menu.sources".localized
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuCell.self)) as! MenuCell
        
        switch (MenuTableRowType(indexPath)) {
        case .yourNews:
            cell.setup(with: "menu.my_news".localized)
        case .settings:
            cell.setup(with: "menu.settings".localized)
        case .allProviders:
            cell.setup(with: "menu.all_sources".localized)
        case .aProvider:
            cell.setup(with: fetchResultController.fetchedObjects![indexPath.row - 1], numberUnreadArticles: 10)
        }
        
        return cell
    }
    

    
}
