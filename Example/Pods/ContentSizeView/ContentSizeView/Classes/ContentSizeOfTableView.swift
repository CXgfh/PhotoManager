//
//  ContentSizeOfTableView.swift
//  ContentSizeView
//
//  Created by Vick on 2022/9/28.
//

import UIKit

//先有视图宽度, 再有contentSize的宽度（内容大小），后调整视图大小
open class ContentSizeOfTableView: UITableView {
    
    private var maximumDisplayHeight: CGFloat?
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    public override var contentSize: CGSize {
        didSet {
            if translatesAutoresizingMaskIntoConstraints {
                sizeToFit()
            } else {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var width = super.intrinsicContentSize.width
        if width <= 0, let superview = self.superview {
            width = superview.frame.width
        }
        
        var height = contentSize.height
        if let max = maximumDisplayHeight, contentSize.height > max {
            height = max
        }
        return CGSize(width: width, height: height)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var width = super.sizeThatFits(size).width
        if width <= 0, let superview = self.superview {
            width = superview.frame.width
        }
        
        var height = contentSize.height
        if let max = maximumDisplayHeight, contentSize.height > max {
            height = max
        }
        return CGSize(width: width, height: height)
    }

    public init(maximumDisplayHeight: CGFloat?, style: UITableView.Style) {
        super.init(frame: .zero, style: style)
        self.maximumDisplayHeight = maximumDisplayHeight
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
