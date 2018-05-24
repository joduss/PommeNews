//
//  PNSideMenuController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit
import SideMenu

class PNSideMenuController: SideMenuController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        SideMenuController.preferences.basic.position = .under
    }
}
