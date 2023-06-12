//
//  VAnimatedTransitioning.swift
//  Vick_Custom_UI
//
//  Created by Vick on 2022/7/1.
//

import UIKit

public enum VTransitioningDirection {
    case top
    case bottom
    case left
    case right
    case center
    
    static prefix func !(direction: VTransitioningDirection) -> VTransitioningDirection {
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
            return .center
        }
    }
    
    var offset: CGVector {
        switch self {
        case .top:
            return CGVector(dx: 0.0, dy: -1.0)
        case .bottom:
            return CGVector(dx: 0.0, dy: 1.0)
        case .left:
            return CGVector(dx: -1.0, dy: 0.0)
        case .right:
            return CGVector(dx: 1.0, dy: 0.0)
        case .center:
            return .zero
        }
    }
    
    var maskedCorners: CACornerMask {
        switch self {
        case .top:
            return [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        case .bottom:
            return [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        case .left:
            return [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        case .right:
            return [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        case .center:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
}

public enum VAnimatedTransitioningType {
    case presented
    case dismissed
}

public class VUIViewControllerAnimated: NSObject {
    private let direction: VTransitioningDirection
    
    private let type: VAnimatedTransitioningType
    
    private var context: UIViewControllerContextTransitioning?
    
    public init(direction: VTransitioningDirection, type: VAnimatedTransitioningType = .presented) {
        self.direction = direction
        self.type = type
        super.init()
    }
}

extension VUIViewControllerAnimated: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.34
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.context = transitionContext
        //实现UIPresentationController协议时present时fromView为nil,dissmiss时toView为nil
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
                  return
        }
        let containerView = transitionContext.containerView
        
        let fromInitialFrame = transitionContext.initialFrame(for: fromVC)
        let toFinalFrame = transitionContext.finalFrame(for: toVC)
        
        //view显示被接管并做动画，实际上frame需要更改，做动画前的准备
        switch type {
        case .presented:
            fromView?.frame = fromInitialFrame
            if direction == .center {
                toView?.alpha = 0
            } else {
                toView?.frame = toFinalFrame.offsetBy(dx: toFinalFrame.width*direction.offset.dx, dy: toFinalFrame.height*direction.offset.dy)
            }
        case .dismissed:
            if direction == .center {
                fromView?.alpha = 1
                toView?.alpha = 0
            } else {
                fromView?.frame = fromInitialFrame
                toView?.frame = toFinalFrame.offsetBy(dx: -toFinalFrame.width*direction.offset.dx, dy: -toFinalFrame.height*direction.offset.dy)
            }
        }
        if let toView = toView {
            containerView.addSubview(toView)
        }
        
        //所有动画都必须发生在containerView中的指定视图
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext)) {
            if let toView = toView {
                if self.direction == .center {
                    toView.alpha = 1
                } else {
                    toView.frame = toFinalFrame
                }
            } else if let fromView = fromView {
                if self.direction == .center {
                    fromView.alpha = 0
                } else {
                    fromView.frame = fromInitialFrame.offsetBy(dx: fromInitialFrame.width*self.direction.offset.dx, dy: fromInitialFrame.height*self.direction.offset.dy)
                }
            }
        } completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        self.context?.completeTransition(transitionCompleted)
    }
    
}
