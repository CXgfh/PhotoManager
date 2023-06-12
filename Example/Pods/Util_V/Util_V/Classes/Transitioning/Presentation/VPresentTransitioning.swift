//
//  VPresentation.swift
//  Vick_Custom_UI
//
//  Created by Vick on 2022/7/4.
//

import UIKit

public class VPresentTransitioning: UIPresentationController {
    
    private let direction: VTransitioningDirection
    
    private let edgeInsets: UIEdgeInsets
    
    private lazy var dimmingView: UIView = {
        let object = UIView()
        object.backgroundColor = .black.withAlphaComponent(0.3)
        object.alpha = 0
        object.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingTap)))
        return object
    }()
    
    private lazy var presentationWrapperView: UIView = {
        let object = UIView()
        object.layer.shadowOpacity = 0.44
        object.layer.shadowRadius = 13
        object.layer.shadowOffset = .init(width: 0, height: -6)
        object.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            object.layer.maskedCorners = direction.maskedCorners
        }
        object.layer.masksToBounds = true
        return object
    }()
    
    public init(direction: VTransitioningDirection,
                edgeInsets: UIEdgeInsets,
                presentedViewController: UIViewController,
                presenting presentingViewController: UIViewController?) {
        self.direction = direction
        self.edgeInsets = edgeInsets
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.modalPresentationStyle = .custom
    }
    
    private override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        fatalError("禁用该初始化方法")
    }
    
    public override var presentedView: UIView? {
        return presentationWrapperView
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        let size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: self.containerView?.bounds.size ?? .zero)
        if size == .zero {
            return CGRect(origin: .zero, size: UIScreen.main.bounds.size)
        } else {
            var origin: CGPoint
            switch direction {
            case .top:
                origin = CGPoint(x: (UIScreen.main.bounds.width - size.width)/2, y: edgeInsets.top)
                
                if #available(iOS 11.0, *), edgeInsets.top != 0 {
                    presentationWrapperView.layer.maskedCorners = VTransitioningDirection.center.maskedCorners
                }
            case .bottom:
                origin = CGPoint(x: (UIScreen.main.bounds.width - size.width)/2, y: UIScreen.main.bounds.height - size.height - edgeInsets.bottom)
                
                if #available(iOS 11.0, *), edgeInsets.bottom != 0 {
                    presentationWrapperView.layer.maskedCorners = VTransitioningDirection.center.maskedCorners
                }
            case .left:
                origin = CGPoint(x: edgeInsets.left, y: (UIScreen.main.bounds.height - size.height)/2)
                
                if #available(iOS 11.0, *), edgeInsets.left != 0 {
                    presentationWrapperView.layer.maskedCorners = VTransitioningDirection.center.maskedCorners
                }
            case .right:
                origin = CGPoint(x: UIScreen.main.bounds.width - size.width - edgeInsets.right, y: (UIScreen.main.bounds.height - size.height)/2)
                
                if #available(iOS 11.0, *), edgeInsets.right != 0 {
                    presentationWrapperView.layer.maskedCorners = VTransitioningDirection.center.maskedCorners
                }
            case .center:
                origin = CGPoint(x: (UIScreen.main.bounds.width - size.width)/2, y: (UIScreen.main.bounds.height - size.height)/2)
            }
            return CGRect(origin: origin, size: size)
        }
    }
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if (container as? UIViewController) == self.presentedViewController {
            self.containerView?.setNeedsLayout()
        }
    }
    
    public override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if (container as? UIViewController) == self.presentedViewController {
            return container.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    public override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = self.containerView?.bounds ?? .zero
        presentationWrapperView.frame = self.frameOfPresentedViewInContainerView
    }
    
    public override func presentationTransitionWillBegin() {
        presentationWrapperView.frame = self.frameOfPresentedViewInContainerView
        if let presentedView = super.presentedView {
            presentedView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            presentedView.frame = presentationWrapperView.bounds
            presentationWrapperView.addSubview(presentedView)
        }
        
        dimmingView.frame = self.containerView?.bounds ?? .zero
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            //在视图控制器转换动画的同时运行指定的动画
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1
            }, completion: nil)
        } else {
            self.dimmingView.alpha = 1
        }
    }
    
    public override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
            presentationWrapperView.subviews.forEach{ $0.removeFromSuperview() }
        }
    }
    
    public override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentedViewController.transitionCoordinator {
            //在视图控制器转换动画的同时运行指定的动画
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0
            }, completion: nil)
        } else {
            self.dimmingView.alpha = 0
        }
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
            presentationWrapperView.subviews.forEach{ $0.removeFromSuperview() }
        }
    }
}

extension VPresentTransitioning {
    @objc private func dimmingTap() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
}

extension VPresentTransitioning: UIViewControllerTransitioningDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VUIViewControllerAnimated(direction: direction, type: .dismissed)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return VUIViewControllerAnimated(direction: direction)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
}
