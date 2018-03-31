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
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
        let toVC = transitionContext.viewController(forKey: .to)
             else {
                return
        }
        
        let container = transitionContext.containerView
        
        container.insertSubview(toVC.view, belowSubview: fromVC.view)

        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        snapshot.tag = MenuHelper.snapshotTag

        container.insertSubview(snapshot, aboveSubview: toVC.view)
        snapshot.isUserInteractionEnabled = false
        snapshot.layer.shadowOpacity = 0.7
        fromVC.view.isHidden = true

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () in
            snapshot.center.x += UIScreen.main.bounds.width * MenuHelper.menuWidthRatio
        }, completion: { _ in
            print("\(container.subviews)")
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromVC.view.isHidden = false
        })
        
    }
    
    
}
