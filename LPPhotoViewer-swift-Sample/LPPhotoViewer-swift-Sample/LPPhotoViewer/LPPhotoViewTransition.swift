//
//  LPPhotoViewTransition.swift
//  LPPhotoViewer
//
//  Created by litt1e-p on 16/4/28.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

enum LPPhotoViewTransitionType: Int
{
    case Present, Dismiss
}

class LPPhotoViewTransition: NSObject, UIViewControllerAnimatedTransitioning
{
    var type:LPPhotoViewTransitionType = .Present
    private let kLPPVTransitionFailedKey = "__FAILED_LPPHOTOVIEWER_TRANSITION__"
    
    init?(transitionType: LPPhotoViewTransitionType) {
        type = transitionType
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        switch type {
            case .Present:
                execPresentAnimation(transitionContext)
            default:
                execDismissAnimation(transitionContext)
        }
    }
    
    private func execPresentAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView()
        let toVc = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        container?.addSubview(toVc!.view)
        toVc!.view.alpha = 0.0
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            toVc!.view.alpha = 1.0
        }) { (finished: Bool) in
            let wasCancel = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!wasCancel)
            if wasCancel {
                print(self.kLPPVTransitionFailedKey)
            }
        }
    }
    
    private func execDismissAnimation(transitionContext: UIViewControllerContextTransitioning) {
        let fromVc = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        fromVc!.view.alpha = 1.0
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: { 
            fromVc!.view.alpha = 0.0
        }) { (finished: Bool) in
            let wasCancel = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!wasCancel)
            if wasCancel {
                fromVc!.view.alpha = 1.0
                print(self.kLPPVTransitionFailedKey)
            } else {
                fromVc!.view.removeFromSuperview()
            }
        }
    }
}
