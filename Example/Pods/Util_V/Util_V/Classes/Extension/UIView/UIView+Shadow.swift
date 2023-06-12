//
//  UIView+Shadow.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIView {
    ///阴影
    func addShadow(color: UIColor = .black, opacity: Float = 0.4, radius: CGFloat = 10, offset: CGSize = .zero) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    
    ///路径绘制阴影，提高性能
    func addShadow(color: UIColor = .black, opacity: Float = 0.4, radius: CGFloat = 10, offset: CGSize = .zero, path: CGPath) {
        layer.shadowPath = path
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
}
