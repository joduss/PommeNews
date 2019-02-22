//
//  MenuContentViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import SideMenu

class ContentViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.sideMenuController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:#imageLiteral(resourceName: "menuButton.pdf"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(showMenu(sender:)))
        }
    }
    
    @objc private func showMenu(sender: UIBarButtonItem) {
        self.sideMenuController?.revealMenu()
    }
    
}
