//
//  MainViewControllerBase.swift
//  PommeNews
//
//  Created by Jonathan Duss on 18.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class MainViewControllerBase: UIViewController {
    
    let interactor = Interactor()
    private let openMenuSegueIdentifier = "openMenuSegueIdentifier"
    
    //MARK: - Life cycle
    //================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture(sender:)))
        pan.edges = .left
        self.view.addGestureRecognizer(pan)
    }
    
    //MARK: - Navigation
    //================================================
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewControllerBase {
            menuVC.modalPresentationStyle = .overFullScreen
            menuVC.transitioningDelegate = self
            menuVC.interactor = interactor
        }
    }
    

    
    //MARK: - Action
    //================================================
    
    @IBAction func openMenu(sender: Any) {
        self.performSegue(withIdentifier: openMenuSegueIdentifier, sender: sender)
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        
        //Get how much we translate the finger on the view and compute the progress of the showing of the menu
        let translation = sender.translation(in: view)
        let progress = MenuHelper.progress(translationInView: translation, viewBounds: view.bounds, direction: .right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: openMenuSegueIdentifier, sender: nil)
        }
    }
    
}

//MARK: - UIViewControllerTransitioningDelegate
//================================================

extension MainViewControllerBase: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }

    
}
