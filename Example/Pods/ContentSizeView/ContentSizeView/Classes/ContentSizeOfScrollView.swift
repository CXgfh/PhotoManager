//
//  ContentSizeScrollView.swift
//  ContentSizeView
//
//  Created by Vick on 2022/9/7.
//

import UIKit

/*
 先有contentSize（内容大小），
 后调整视图大小
 */
open class ContentSizeOfScrollView: UIScrollView {
    
    private var maximumDisplayHeight: CGFloat?
    private var maximumDisplayWidth: CGFloat?
    
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
        var width = contentSize.width
        if let max = maximumDisplayWidth, contentSize.width > max {
            width = max
        }
        
        var height = contentSize.height
        if let max = maximumDisplayHeight, contentSize.height > max {
            height = max
        }
        return CGSize(width: width, height: height)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var width = contentSize.width
        if let max = maximumDisplayWidth, contentSize.width > max {
            width = max
        }
        
        var height = contentSize.height
        if let max = maximumDisplayHeight, contentSize.height > max {
            height = max
        }
        return CGSize(width: width, height: height)
    }
    
    public init(maximumDisplayHeight: CGFloat? = nil, maximumDisplayWidth: CGFloat? = nil) {
        super.init(frame: .zero)
        self.maximumDisplayHeight = maximumDisplayHeight
        self.maximumDisplayWidth = maximumDisplayWidth
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
