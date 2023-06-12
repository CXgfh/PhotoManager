//
//  UIViewController.swift
//  VTransitioning
//
//  Created by Vick on 2022/10/27.
//

import UIKit

//MARK: --- Present ----
public extension UIViewController {
    func present(vc: UIViewController,
                 direction: VTransitioningDirection,
                 edgeInsets: UIEdgeInsets = .zero,
                 modalPresentationStyle: UIModalPresentationStyle,
                 animated flag: Bool,
                 completion: (() -> Void)? = nil) {
        let transitioning = VPresentTransitioning(direction: direction,
                                                  edgeInsets: edgeInsets,
                                                  presentedViewController: vc,
                                                  presenting: self)
        vc.transitioningDelegate = transitioning
        vc.modalTransitionStyle = modalTransitionStyle
        self.present(vc, animated: flag)
    }
}

//MARK: --Interactive----
public extension UIViewController {
    private static var __transition = "VInteractiveTransitioning"
    var _transition: UIViewControllerTransitioningDelegate? {
        get {
            return objc_getAssociatedObject(self, &Self.__transition) as? VInteractiveTransitioning
        }
        set {
            objc_setAssociatedObject(self, &Self.__transition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func swipePresent(vc: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        let swipeTransitioning = VInteractiveTransitioning(direction: .right)
        vc.transitioningDelegate = swipeTransitioning
        vc.modalPresentationStyle = .fullScreen
        _transition = swipeTransitioning
        self.present(vc, animated: flag, completion: completion)
    }
}
