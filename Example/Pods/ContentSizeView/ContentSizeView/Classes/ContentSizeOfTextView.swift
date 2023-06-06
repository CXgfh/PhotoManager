//
//  ContentSizeOfTextView.swift
//  ContentSizeView
//
//  Created by V on 2023/2/16.
//

import UIKit
/*
 内容（_UITextLayoutFragmentView）与容器（_UITextLayoutCanvasView）上下间距8;
 初始内容为光标;
 contentSize高度 = 字体行高 * 行数 + 16，结果向上取整;
 默认字体为11号系统字体
 */
open class ContentSizeOfTextView: UITextView {
    
    public var displayWidth: CGFloat = 0 {
        didSet {
            if translatesAutoresizingMaskIntoConstraints {
                sizeToFit()
            } else {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public var maximumDisplayHeight: CGFloat?

    public override var contentSize: CGSize {
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
        newSize()
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        newSize()
    }
    
    public init(displayWidth: CGFloat = 0) {
        self.displayWidth = displayWidth
        super.init(frame: .zero, textContainer: nil)
    }
    
    private func newSize() -> CGSize {
        let useFont = font ?? UIFont.systemFont(ofSize: 11)
        var height = ceil(useFont.lineHeight + 16)
        
        if contentSize.height > height {
            height = contentSize.height
        }
        
        if let max = maximumDisplayHeight, height > max {
            height = max
        }
        
        return CGSize(width: displayWidth, height: height)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
