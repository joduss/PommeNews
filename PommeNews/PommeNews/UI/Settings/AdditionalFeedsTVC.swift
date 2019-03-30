//
//  AdditionalFeedsTVC.swift
//  PommeNews
//
//  Created by Jonathan Duss on 25.03.19.
//  Copyright © 2019 Swizapp. All rights reserved.
//

import UIKit
import CoreData

class AdditionalFeedsTVC: UITableViewController {
    
    private let rssFeedStore = Inject.component(RSSManager.self).rssFeedStore
    private var resultsController: NSFetchedResultsController<RssFeed>!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let request = RssFeedRequest().addedByUser(true).create()
        resultsController = NSFetchedResultsController<RssFeed>(fetchRequest: request,
                                                                managedObjectContext: CoreDataStack.shared.context!,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        resultsController.delegate = self
        try? resultsController.performFetch()
    }

    // MARK: - Table view data source + delegate
    //===================================================================

    override func numberOfSections(in tableView: UITableView) -> Int {
        return resultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController?.fetchedObjects?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let feed: RssFeed = resultsController.object(at: indexPath)
        cell.textLabel?.text = feed.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let feed: RssFeed = resultsController.object(at: indexPath)
            rssFeedStore.remove(feed: feed)
        }
    }
 
    // MARK: Actions
    //===================================================================
    
    @IBAction func addFeed(_ sender: Any) {
        let alert = UIAlertController(title: "settings.new_feed.popup.title".localized,
                                      message: "settings.new_feed.popup.message".localized,
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "settings.new_feed.popup.input.name.placeholder".localized
        })
        
        alert.addTextField(configurationHandler: { tf in
            tf.placeholder = "settings.new_feed.popup.input.url.placeholder".localized
        })
        
        alert.addAction(UIAlertAction(title: "popup.cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "popup.ok".localized, style: .default, handler: { action in
            if let name = alert.textFields?[0].text, let url = URL(string: alert.textFields?[1].text) {
                self.rssFeedStore.addNewUserFeed(name: name, url: url)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Fetch Results Controller Delegate
//==================================================================

extension AdditionalFeedsTVC: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
}

