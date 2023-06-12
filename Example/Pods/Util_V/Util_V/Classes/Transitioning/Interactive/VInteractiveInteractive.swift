//
//  VInteractiveTransitioning.swift
//  Vick_Custom_UI
//
//  Created by Vick on 2022/7/1.
//

import UIKit

class VInteractiveInteractive: UIPercentDrivenInteractiveTransition {
    private let direction: VTransitioningDirection
    
    private let gesture: UIScreenEdgePanGestureRecognizer
    
    private var transitionContext: UIViewControllerContextTransitioning?
    
    init(direction: VTransitioningDirection, gesture: UIScreenEdgePanGestureRecognizer) {
        self.direction = direction
        self.gesture = gesture
        super.init()
        self.gesture.addTarget(self, action: #selector(handleSwipeUpdate))
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        super.startInteractiveTransition(transitionContext)
    }
    
    @objc private func handleSwipeUpdate(_ pan: UIScreenEdgePanGestureRecognizer) {
        guard let containerView = transitionContext?.containerView else {
            return
        }
        switch pan.state {
        case .began:
            pan.setTranslation(.zero, in: containerView)
        case .changed:
            update(swipePercent(pan, in: containerView))
        case .ended:
            if swipePercent(pan, in: containerView) > 0.5 {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }
    
    private func swipePercent(_ pan: UIScreenEdgePanGestureRecognizer, in containerView: UIView) -> CGFloat {
        let point = pan.location(in: containerView)
        switch direction {
        case .top:
            return point.y / containerView.frame.height
        case .bottom:
            return 1 - point.y / containerView.frame.height
        case .left:
            return point.x / containerView.frame.width
        case .right:
            return 1 - point.x / containerView.frame.width
        default:
            return .zero
        }
    }
}


