//
//  SideMenuDismissAnimator.swift
//  PommeNews
//
//  Created by Jonathan Duss on 27.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

class DismissMenuAnimator : NSObject {
}

extension DismissMenuAnimator : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        // 1
        let snapshot = containerView.viewWithTag(MenuHelper.snapshotTag)
        
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                // 2
                snapshot?.frame = CGRect(origin: CGPoint.zero, size: UIScreen.main.bounds.size)
        },
            completion: { _ in
                let didTransitionComplete = !transitionContext.transitionWasCancelled
                if didTransitionComplete {
                    // 3
                    snapshot?.removeFromSuperview()
                }
                transitionContext.completeTransition(didTransitionComplete)
        }
        )
    }
}


