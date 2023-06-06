//
//  ContentSizeOfButton.swift
//  ContentSizeView
//
//  Created by Vick on 2022/9/7.
//

import UIKit

/*
 button布局以文本间距为准(先绘制了文本)
 主要影响图文间距的属性为imageEdgeInsets.right(左侧图标时)：
    pdf格式图会自动放大，导致没有图文间距
    right和实际间距可能不一制
 */

open class ContentSizeOfButton: UIButton {
    
    public var maxCornerRadius: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override var titleEdgeInsets: UIEdgeInsets {
        didSet {
            if translatesAutoresizingMaskIntoConstraints {
                sizeToFit()
            } else {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public override var intrinsicContentSize: CGSize {
        newSize(super.intrinsicContentSize, edge: titleEdgeInsets)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        newSize(super.sizeThatFits(size), edge: titleEdgeInsets)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let maxCornerRadius = maxCornerRadius {
            var maximum = min(bounds.width/2, bounds.height/2)
            maximum = min(maxCornerRadius, maximum)
            layer.cornerRadius = maximum
            layer.masksToBounds = true
        }
    }
}
