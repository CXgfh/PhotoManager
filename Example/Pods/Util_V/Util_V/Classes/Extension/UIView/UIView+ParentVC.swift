//
//  UIView+ParentVC.swift
//  Util
//
//  Created by Vick on 2022/9/23.
//

import UIKit

public extension UIView {
    var viewController: UIViewController? {
        for view in sequence(first: self.superview, next: {$0?.superview}) {
            if let responder = view?.next as? UIViewController {
                return responder
            }
        }
        return nil
    }
}
