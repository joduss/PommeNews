//
//  SideMenuAnimator.swift
//  PommeNews
//
//  Created by Jonathan Duss on 18.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class PresentMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MenuHelper.AnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
        let toVC = transitionContext.viewController(forKey: .to)
             else {
                return
        }
        
        let container = transitionContext.containerView
        
        //Inset the menuVC under the current view. The container view contains the view to animate.
        container.insertSubview(toVC.view, belowSubview: fromVC.view)

        //Create a snapshot of the current VC for the animation and so that it's not possible to interect with it!
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        snapshot.tag = MenuHelper.snapshotTag

        //Insert the snapshot
        container.insertSubview(snapshot, aboveSubview: toVC.view)
        snapshot.isUserInteractionEnabled = false
        snapshot.layer.shadowOpacity = 0.7
        fromVC.view.isHidden = true

        //Animate
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () in
            snapshot.center.x += UIScreen.main.bounds.width * SideMenuConfiguration.menuRelativeWidth
        }, completion: { _ in
            print("\(container.subviews)")
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromVC.view.isHidden = false
        })
        
    }
    
}
