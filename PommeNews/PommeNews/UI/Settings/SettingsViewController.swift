//
//  SettingsViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import ZaJoLibrary

class SettingsViewController: ContentTableViewController {
    
    
    @IBOutlet weak var hiddenStreamsCell: UITableViewCell!
    @IBOutlet weak var myStreamsCell: UITableViewCell!
    @IBOutlet weak var emptyCacheCell: UITableViewCell!
    @IBOutlet weak var intervalSelector: UISegmentedControl!
    
    private let rssManager = Inject.component(RSSManager.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings.Title".localized
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        try? CoreDataStack.shared.save()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case hiddenStreamsCell:
            break
        case myStreamsCell:
            break
        case emptyCacheCell:
            rssManager.cleanCache()
            tableView.deselectRow(at: tableView.indexPath(for: emptyCacheCell)!, animated: true)
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier  {
        case "MyStreams":
            let vc = segue.destination as! FeedSelectionViewController
            vc.mode = .favorite
        case "HiddenStreams":
            let vc = segue.destination as! FeedSelectionViewController
            vc.mode = .hidden
        default:
            break
        }
    }
    
}
