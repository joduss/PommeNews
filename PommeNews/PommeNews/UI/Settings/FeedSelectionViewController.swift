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

class FeedSelectionViewController: UITableViewController {
    
    private var feeds : [RssFeed] = []
    public var mode: StreamManagementMode = .favorite
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: String(describing: FeedManagementCell.self),
                                 bundle: nil),
                           forCellReuseIdentifier: String(describing: FeedManagementCell.self))
        
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        try? CoreDataStack.shared.save()
    }
    
    private func configureTitle() {
        switch mode {
        case .favorite:
            self.title = "settings.stream_management.favorites".localized
        case .hidden:
            self.title = "settings.stream_management.hidden".localized
        }
    }
    
    
}

extension FeedSelectionViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedManagementCell.self)) as! FeedManagementCell
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57
    }
    
}
