//
//  StreamManagementViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 06.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import CoreData

enum StreamManagementMode {
    case hidden
    case favorite
}

class StreamManagementViewController: UITableViewController {
    
    private var feeds : [RssFeed] = []
    public var mode: StreamManagementMode = .favorite
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: MenuFeedCell.self),
                                 bundle: nil),
                           forCellReuseIdentifier: String(describing: MenuFeedCell.self))
        
        
        let request: NSFetchRequest<RssFeed> = RssFeed.fetchRequest()
        
        CoreDataStack.shared.context.perform {
            do {
                self.feeds = try request.execute()
                self.tableView.reloadData()
            }
            catch {
                
            }
        }
        
    }
    
    
}

extension StreamManagementViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuFeedCell.self)) as! MenuFeedCell
        cell.setup(with: self.feeds[indexPath.row], mode: self.mode)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.mode {
        case .favorite:
            self.feeds[indexPath.row].favorite = !self.feeds[indexPath.row].favorite
        case .hidden:
            self.feeds[indexPath.row].hidden = !self.feeds[indexPath.row].hidden
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        switch self.mode {
        case .favorite:
            self.feeds[indexPath.row].favorite = !self.feeds[indexPath.row].favorite
        case .hidden:
            self.feeds[indexPath.row].hidden = !self.feeds[indexPath.row].hidden
        }
    }
    
}
