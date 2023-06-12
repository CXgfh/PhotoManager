//
//  VTransitioningDelegate.swift
//  Vick_Custom_UI
//
//  Created by Vick on 2022/7/1.
//

import UIKit

public class VInteractiveTransitioning: NSObject {
    
    private var transitionInProgress = false
    
    private let direction: VTransitioningDirection
    
    private var dismissedGesture: UIScreenEdgePanGestureRecognizer?
    
    private var presentedGesture: UIScreenEdgePanGestureRecognizer?
    
    public var presentedEdge: UIRectEdge {
        switch direction {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .left:
            return .left
        case .right:
            return .right
        case .center:
            return .all
        }
    }
    
    public var dismissedEdge: UIRectEdge {
        switch direction {
        case .top:
            return .bottom
        case .bottom:
            return .top
        case .left:
            return .right
        case .right:
            return .left
        case .center:
            return .all
        }
    }
    
    public init(direction: VTransitioningDirection) {
        self.direction = direction
        super.init()
    }
}

extension VInteractiveTransitioning {
    @objc private func dissmissSwipe(_ sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began {
            transitionInProgress = true
            if let vc = sender.view?.next as? UIViewController {
                vc.dismiss(animated: true)
            }
        } else if sender.state == .ended {
            transitionInProgress = false
        }
    }
}

extension VInteractiveTransitioning: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(dissmissSwipe))
        gesture.edges = dismissedEdge
        presented.view.addGestureRecognizer(gesture)
        dismissedGesture = gesture
        return VUIViewControllerAnimated(direction: direction)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VUIViewControllerAnimated(direction: direction, type: .dismissed)
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let gesture = presentedGesture,
           transitionInProgress {
            return VInteractiveInteractive(direction: direction, gesture: gesture)
        }
        return nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let gesture = dismissedGesture,
           transitionInProgress {
            return VInteractiveInteractive(direction: !direction, gesture: gesture)
        }
        return nil
    }
}
