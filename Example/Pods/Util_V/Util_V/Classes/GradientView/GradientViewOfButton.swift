//
//  GradientViewOfButton.swift
//  GradientView
//
//  Created by Vick on 2022/9/22.
//

import UIKit

public class GradientViewOfButton: UIButton {
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
    
    private lazy var gradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .axial
        self.layer.addSublayer(gradientLayer)
        return gradientLayer
    }()
    
    private override init(frame: CGRect) {
        fatalError("禁用该初始化")
    }
    
    public init(direction: GradientDirection) {
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
        super.draw(rect)
        gradientLayer.frame = rect
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
