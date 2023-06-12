//
//  BaseNavigationController.swift
//  BaseNavigationBar
//
//  Created by Vick on 2022/10/25.
//

import UIKit

/*
 CATransaction.begin()
 CATransaction.setCompletionBlock {
     //do
 }
 navigationController?.popViewController(animated: true)
 CATransaction.commit()
 */

public class BaseNavigationController: UINavigationController {
    
    private let backImage: UIImage?
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    public init(rootViewController: UIViewController, backImage: UIImage?) {
        self.backImage = backImage
        if rootViewController.navigationItem.backBarButtonItem == nil {
            var item: UIBarButtonItem
            if #available(iOS 13.0, *) {
                item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            } else {
                item = .init(image: backImage, style: .plain, target: nil, action: nil)
            }
            rootViewController.navigationItem.backBarButtonItem = item
        }
        super.init(rootViewController: rootViewController)
        if #available(iOS 13.0, *) {
            let appearance = navigationBar.standardAppearance
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationBar.shadowImage = UIImage()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BaseNavigationController {
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewController.navigationItem.backBarButtonItem == nil {
            var item: UIBarButtonItem
            if #available(iOS 13.0, *) {
                item = .init(title: "", style: .plain, target: nil, action: nil)
            } else {
                item = .init(image: backImage, style: .plain, target: nil, action: nil)
            }
            viewController.navigationItem.backBarButtonItem = item
        }
        super.pushViewController(viewController, animated: animated)
    }
}

