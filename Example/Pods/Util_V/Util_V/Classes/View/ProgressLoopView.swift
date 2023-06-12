//
//  ProgressView.swift
//  SliderIndicator
//
//  Created by V on 2023/2/9.
//

import UIKit

open class ProgressLoopView: UIView {
    
    public var progress: Double = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var progressColor: UIColor = UIColor(hex: 0xF57ACC)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        var endAngle = CGFloat.pi/2*3
        endAngle -= 2*CGFloat.pi*progress
        
        let path = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width/2-4, startAngle: CGFloat.pi/2*3, endAngle: endAngle, clockwise: false)
        
        context.setLineCap(.round)
        context.setLineWidth(3)
        context.setStrokeColor(progressColor.cgColor)
        context.addPath(path.cgPath)
        context.strokePath()
    }

}


