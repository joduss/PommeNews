//
//  SideMenuDismissAnimator.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


class DismissMenuAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MenuHelper.AnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // Get the snapshot view that shows the VC that is partially visible
        let snapshot = transitionContext.containerView.viewWithTag(MenuHelper.snapshotTag)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                // Animate to the original position without Menu
                snapshot?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        },
            completion: { _ in
                let didTransitionComplete = !transitionContext.transitionWasCancelled
                if didTransitionComplete {
                    snapshot?.removeFromSuperview()
                }
                transitionContext.completeTransition(didTransitionComplete)
        }
        )
    }
}


