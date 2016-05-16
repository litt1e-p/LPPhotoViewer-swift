//
//  LPPhotoViewer+TransitionDelegate.swift
//  litt1e-p
//
//  Created by paul on 16/4/28.
//  Copyright © 2016年 litt1e-p. All rights reserved.
//

import UIKit

extension LPPhotoViewer: UIViewControllerTransitioningDelegate
{
    func transitionMethod(type: LPPhotoViewTransitionType) -> UIViewControllerAnimatedTransitioning? {
        if customTransition && customTransitionDelegate != nil {
            return customTransitionDelegate?.genericTrantion(type)
        } else {
            return LPPhotoViewTransition(transitionType: type)
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionMethod(.Present)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transitionMethod(.Dismiss)
    }
}
