//
//  MenuViewController.swift
//  PommeNews
//
//  Created by Jonathan Duss on 08.04.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class MenuViewController: MenuViewControllerBase {
    
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
        view.frame = CGRect(x: 0, y: 0, width: 250, height: 100)
        
        self.tableView.tableHeaderView = view
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
    
    
}



extension MenuViewController: UITableViewDelegate {
    
}


extension MenuViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuCell.self)) as! MenuCell
        
        cell.textLabel?.text = "The cell content"
        
        return cell
    }
    
}
