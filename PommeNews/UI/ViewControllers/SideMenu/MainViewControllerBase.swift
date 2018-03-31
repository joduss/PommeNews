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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture(sender:)))
        pan.edges = .left
        self.view.addGestureRecognizer(pan)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let menuVC = segue.destination as? MenuViewControllerBase {
            menuVC.modalPresentationStyle = .overFullScreen
            menuVC.transitioningDelegate = self
            menuVC.interactor = interactor
        }
    }
    
    @IBAction func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.progress(translationInView: translation, viewBounds: view.bounds, direction: .right)

        print("Progerss is: \(progress)")
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }
    
}

extension MainViewControllerBase: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("Has Started \(interactor.hasStarted)")
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        print("Has Started? \(interactor.hasStarted)")
        return interactor.hasStarted ? interactor : nil
    }

    
}
