//
//  Scene.swift
//  PommeNews
//
//  Created by Jonathan Duss on 24.05.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class Scene {
    
    
    
    static var settingsViewController: UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: SettingsViewController.self) + "Container")
    }
    
    static var articlesListViewController: ArticlesListVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ArticlesListVC.self)) as! ArticlesListVC
    }
    
}
