//
//  UIView+Add.swift
//  Util
//
//  Created by Vick on 2022/9/20.
//

import UIKit

public extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for index in subviews {
            index.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(index)
        }
    }
    
    func addController(_ subController: UIViewController) {
        if let parent = self.viewController {
            parent.addChild(subController)
            subController.didMove(toParent: parent)
        }
    }
}
