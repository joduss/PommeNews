//
//  MenuViewControllerBase.swift
//  PommeNews
//
//  Created by Jonathan Duss on 18.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit



class MenuViewControllerBase: UIViewController {
    
    @IBOutlet weak var closeMenuButtonWidthConstraint: NSLayoutConstraint!

    
    // 1
    var interactor: Interactor? = nil
    // 2
    @IBAction private func handleGesture(sender: UIPanGestureRecognizer) {
        // 3
        let translation = sender.translation(in: view)
        
        // 4
        let progress = MenuHelper.progress(translationInView: translation, viewBounds: view.bounds, direction: .left)
        
        // 5
        
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    

    @IBAction private func closeMenu(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
