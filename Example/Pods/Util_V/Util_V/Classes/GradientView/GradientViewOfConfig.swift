//
//  GradientViewOfConfig.swift
//  GradientView
//
//  Created by Vick on 2022/9/22.
//

import UIKit

public enum GradientDirection {
    case custom(_ star: CGPoint, _ end: CGPoint)
    case diagonal
    case obliqueDiagonal
    case vertical
    case horizontal
}

public struct GradientGap {
    var leftTop: CGFloat
    var rightTop: CGFloat
    var leftBottom: CGFloat
    var rightBottom: CGFloat
    
    public init() {
        leftTop = 0
        rightTop = 0
        leftBottom = 0
        rightBottom = 0
    }
    
    public init(leftTop: CGFloat, rightTop: CGFloat, leftBottom: CGFloat, rightBottom: CGFloat) {
        self.leftTop = leftTop
        self.rightTop = rightTop
        self.leftBottom = leftBottom
        self.rightBottom = rightBottom
    }
}
