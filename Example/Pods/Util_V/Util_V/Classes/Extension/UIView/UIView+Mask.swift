//
//  UIView+Mask.swift
//  VUIView
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIView {
    ///iOS10掩盖层实现部分圆角
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.layoutIfNeeded()
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

