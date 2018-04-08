//
//  MenuViewControllerBase.swift
//  PommeNews
//
//  Created by Jonathan Duss on 18.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit



class MenuViewControllerBase: UIViewController {
    
    var interactor: Interactor? = nil
    
    //MARK: - Life cycle
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIView()
        self.view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
        button.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                      multiplier: 1.0 - SideMenuConfiguration.menuRelativeWidth,
                                      constant: 0).isActive = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(sender:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMainView(sender:)))
        
        button.addGestureRecognizer(tap)
        button.addGestureRecognizer(pan)
        
        self.view.updateConstraints()
    }
    
    
    //MARK: - Actions
    //================================================
    
    @objc private func handleGesture(sender: UIPanGestureRecognizer) {
        
        //Get the translation in the view.
        let translation = sender.translation(in: view)
        
        //and compute the progress of the translation to show the menu
        let progress = MenuHelper.progress(translationInView: translation, viewBounds: view.bounds, direction: .left)
        
        // We map the state and the closure is what to do on state "Start"
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                // 6
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func tapMainView(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func closeMenu(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
