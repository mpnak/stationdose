//
//  TransitionAnimations.swift
//  Stationdose
//
//  Created by Developer on 11/26/15.
//  Copyright © 2015 Stationdose. All rights reserved.
//

import UIKit


// MARK: TransitionManager Extension

enum TransitionManagerAnimations {
    case Fade
    
    func transitionAnimation () -> TransitionManagerAnimation {
        switch self {
        case .Fade:
            return FadeTransitionAnimation()
        }
    }
}

extension TransitionManager {
    convenience init (transition: TransitionManagerAnimations) {
        self.init (transitionAnimation: transition.transitionAnimation())
    }
}

// MARK: - Fade Transition

class FadeTransitionAnimation: TransitionManagerAnimation {
    override func transition(
        container: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        isDismissing: Bool,
        duration: NSTimeInterval,
        completion: () -> Void) {
            if isDismissing {
                closeAnimation(container,
                    fromViewController: fromViewController,
                    toViewController: toViewController,
                    duration: 0.8,
                    completion: completion)
            } else {
                openAnimation(container,
                    fromViewController: fromViewController,
                    toViewController: toViewController,
                    duration: 0.8,
                    completion: completion)
            }
    }
    
    func openAnimation (
        container: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        duration: NSTimeInterval,
        completion: () -> Void) {
            toViewController.view.alpha = 0
            container.addSubview(toViewController.view)
            UIView.animateWithDuration(duration,
                animations: {
                    toViewController.view.alpha = 1
                }, completion: {
                    finished in
                    fromViewController.view.alpha = 1
                    completion()
            })
    }
    
    func closeAnimation (
        container: UIView,
        fromViewController: UIViewController,
        toViewController: UIViewController,
        duration: NSTimeInterval,
        completion: () -> Void) {
            container.addSubview(toViewController.view)
            container.bringSubviewToFront(fromViewController.view)
            UIView.animateWithDuration(duration,
                animations: {
                    fromViewController.view.alpha = 0
                }, completion: {
                    finished in
                    completion()
            })
    }
}