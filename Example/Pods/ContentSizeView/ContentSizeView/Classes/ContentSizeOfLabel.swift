//
//  ContentSizeOfLabel.swift
//  ContentSizeView
//
//  Created by Vick on 2022/9/12.
//

import UIKit

//继承了UIContentSizeCategoryAdjusting，文本大小自适应，先确定了size才添加到父视图
open class ContentSizeOfLabel: UILabel {
    
    public var maxCornerRadius: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var titleEdgeInsets: UIEdgeInsets = .zero {
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
        return newSize(super.intrinsicContentSize, edge: titleEdgeInsets)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return newSize(super.sizeThatFits(size), edge: titleEdgeInsets)
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: titleEdgeInsets))
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        super.textRect(forBounds: bounds.inset(by: titleEdgeInsets), limitedToNumberOfLines: numberOfLines)
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
