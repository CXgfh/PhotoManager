//
//  ContentSizeOfView.swift
//  ContentSizeView
//
//  Created by Vick on 2022/10/19.
//

import UIKit

open class ContentSizeOfView: UIView {
    
    public var maxCornerRadius: CGFloat? {
        didSet {
            setNeedsLayout()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let maxCornerRadius = maxCornerRadius {
            var maximum = min(self.frame.size.width/2, self.frame.size.height/2)
            maximum = min(maxCornerRadius, maximum)
            layer.cornerRadius = maximum
            layer.masksToBounds = true
        }
    }
}
