//
//  MenuHelper.swift
//  PommeNews
//
//  Created by Jonathan Duss on 18.03.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit


struct MenuHelper {
    
    static let snapshotTag = 123456
    
    static let AnimationDuration = 0.3
    
    static func progress(translationInView translation: CGPoint, viewBounds: CGRect, direction: Direction) -> CGFloat {
        let pointInView = translation.x
        let axisLength = viewBounds.width
    
        let movementInAxis = abs(pointInView / axisLength)
        
        return fmin(1, movementInAxis)
    }
    
    
    static func mapGestureStateToInteractor(gestureState:UIGestureRecognizerState, progress:CGFloat, interactor: Interactor?, triggerSegue: () -> Void){
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            print("Begin")
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            print("Change with progress \(progress) | should finish: \(progress > SideMenuConfiguration.percentThreshold)")
            interactor.shouldFinish = progress > SideMenuConfiguration.percentThreshold
            interactor.update(progress)
        case .cancelled:
            print("Cancel")
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            print("Ended")
            interactor.hasStarted = false
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
        default:
            break
        }
    }
}
