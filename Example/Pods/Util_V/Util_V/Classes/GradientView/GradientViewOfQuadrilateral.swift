//
//  GradientViewOfQuadrilateral.swift
//  GradientView
//
//  Created by Vick on 2022/9/22.
//

import UIKit

public class GradientViewOfQuadrilateral: UIView {
    
    public var isGradient = true {
        didSet {
            gradientLayer.isHidden = !isGradient
        }
    }
    
    public var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var borderWidth: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var borderColor: CGColor = UIColor.clear.cgColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var colors: [CGColor] = [] {
        didSet {
            gradientLayer.colors = colors
            setNeedsDisplay()
        }
    }
    
    public var locations: [NSNumber] = [] {
        didSet {
            gradientLayer.locations = locations
            setNeedsDisplay()
        }
    }
    
    private let gap: GradientGap

    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        self.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    
    private lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        self.layer.mask = maskLayer
        return maskLayer
    }()
    
    private override init(frame: CGRect) {
        fatalError("禁用该初始化")
    }
    
    public init(direction: GradientDirection, gap: GradientGap = .init()) {
        self.gap = gap
        super.init(frame: .zero)
        switch direction {
        case .custom(let star, let end):
            gradientLayer.startPoint = star
            gradientLayer.endPoint = end
        case .diagonal:
            gradientLayer.startPoint = .zero
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .obliqueDiagonal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        gradientLayer.frame = rect
        
        let leftTiltAngle = tan((gap.leftBottom - gap.leftTop)/rect.height)
        let rightTiltAngle = tan((gap.rightBottom - gap.rightTop)/rect.height)
        let leftTopCenter = CGPoint(x: gap.leftTop+cornerRadius/2+borderWidth, y: cornerRadius/2+borderWidth)
        let rightTopCenter = CGPoint(x: rect.width-gap.rightTop-cornerRadius/2-borderWidth, y: cornerRadius/2+borderWidth)
        let leftBottomCenter = CGPoint(x: gap.leftBottom+cornerRadius/2+borderWidth, y: rect.height-cornerRadius/2-borderWidth)
        let rightBottomCenter = CGPoint(x: rect.width-gap.rightBottom-cornerRadius/2-borderWidth, y: rect.height-cornerRadius/2-borderWidth)
        
        let path = UIBezierPath()
        path.addArc(withCenter: leftTopCenter, radius: cornerRadius/2, startAngle: CGFloat.pi-leftTiltAngle, endAngle: CGFloat.pi/2*3, clockwise: true)
        path.addArc(withCenter: rightTopCenter, radius: cornerRadius/2, startAngle: CGFloat.pi/2*3, endAngle: rightTiltAngle, clockwise: true)
        path.addArc(withCenter: rightBottomCenter, radius: cornerRadius/2, startAngle: rightTiltAngle, endAngle: CGFloat.pi/2, clockwise: true)
        path.addArc(withCenter: leftBottomCenter, radius: cornerRadius/2, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi-leftTiltAngle, clockwise: true)
        path.close()
        
        maskLayer.path = path.cgPath
        
        context.setLineWidth(borderWidth)
        context.setStrokeColor(borderColor)
        context.setFillColor(UIColor.clear.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        context.strokePath()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
