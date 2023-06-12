//
//  GradientViewOfText.swift
//  GradientView
//
//  Created by Vick on 2022/9/22.
//

import UIKit

public class GradientViewOfText: UILabel {
    
    public var colors: [CGColor] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var locations: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let direction: GradientDirection
    
    private override init(frame: CGRect) {
        fatalError("禁用该初始化")
    }
    
    public init(direction: GradientDirection) {
        self.direction = direction
        super.init(frame: .zero)
    }
    
    public override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        //获取当前文本
        guard let context = UIGraphicsGetCurrentContext(),
              let text = context.makeImage() else {
            return
        }
        context.clear(rect) //清空当前绘制
        context.clip(to: rect, mask: text) //将文本设置为mark
        //绘制渐变色图层
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) else {
            return
        }
        let starPoint: CGPoint
        let endPoint: CGPoint
        switch direction {
        case .custom(let star, let end):
            starPoint = CGPoint(x: rect.width*star.x, y: rect.height*star.y)
            endPoint = CGPoint(x: rect.width*end.x, y: rect.height*end.y)
        case .diagonal:
            starPoint = CGPoint(x: 0, y: 0)
            endPoint = CGPoint(x: rect.width, y: rect.height)
        case .obliqueDiagonal:
            starPoint = CGPoint(x: 0, y: rect.height)
            endPoint = CGPoint(x: rect.width, y: 0)
        case .vertical:
            fatalError("无效参数")
        case .horizontal:
            starPoint = CGPoint(x: 0, y: rect.height*0.5)
            endPoint = CGPoint(x: rect.width, y: rect.height*0.5)
        }
        context.drawLinearGradient(gradient, start: starPoint, end: endPoint, options:  [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
