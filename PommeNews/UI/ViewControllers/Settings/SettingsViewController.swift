//
//  SettingsViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 03.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class SettingsViewController: UITableViewController {
    
    
    @IBOutlet weak var hiddenStreamsCell: UITableViewCell!
    @IBOutlet weak var myStreamsCell: UITableViewCell!
    @IBOutlet weak var emptyCacheCell: UITableViewCell!
    
    @IBOutlet weak var intervalSelector: UISegmentedControl!
    
    private let rssManager = Inject.component(RSSManager.self)
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case hiddenStreamsCell:
            break
        case myStreamsCell:
            break
        case emptyCacheCell:
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MyStreams" {
            let vc = segue.destination as! StreamManagementViewController
            vc.mode = .favorite
        }
        else if segue.identifier == "HiddenStreams" {
            let vc = segue.destination as! StreamManagementViewController
            vc.mode = .hidden
        }
    }
    
}
