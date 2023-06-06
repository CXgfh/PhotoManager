//
//  SliderIndicator.swift
//  SliderIndicator
//
//  Created by Vick on 2022/10/9.
//

import UIKit
import Util_V
import SnapKit

public class SliderDefaultIndicator: UIView, SliderIndicatorView {
    public var extraContentView: UIView {
        return extraView
    }
    
    public var indicatorContentView: UIView {
        return indicatorView
    }
    
    public var contentView: UIView {
        return self
    }
    
    public var delegate: SliderIndicatorDelegate?
    
    private let config: SliderConfig
    
    private var indicatorOffset: NSLayoutConstraint?
    
    //是否正在拖拽
    private var dragging = false
    
    private var unitSize: CGFloat {
        layoutIfNeeded()
        if config.direction == .horizontal {
            return (self.bounds.width - config.indicatorSize - config.extraViewSize)/100.0
        } else {
            return (self.bounds.height - config.indicatorSize - config.extraViewSize)/100.0
        }
    }
    
    public var multiplied: Float = 0 {
        didSet {
            if multiplied != oldValue {
                dragging = false
                var correction = multiplied
                if correction < 0 {
                    correction = 0
                } else if correction > 1 {
                    correction = 1
                }
                progress = unitSize*CGFloat(correction)*100
            }
        }
    }
    
    private var progress: CGFloat = 0 {
        didSet {
            if progress != oldValue {
                if config.direction == .horizontal {
                    indicatorOffset?.constant = progress
                } else {
                    indicatorOffset?.constant = -progress
                }
                if dragging, progress != oldValue {
                    let newValue = progress/unitSize/100.0
                    multiplied = Float(newValue)
                    delegate?.sliderChanged(self, to: multiplied)
                }
            }
        }
    }
    
    private lazy var extraView = UIView()
    
    private lazy var sliderView: UIView = {
        let object = UIView()
        object.backgroundColor = config.sliderColor
        object.layer.cornerRadius = config.sliderSize/2
        object.layer.masksToBounds = true
        return object
    }()
    
    private lazy var progressView: UIView = {
        let object = UIView()
        object.backgroundColor = config.progressColor
        return object
    }()
    
    private lazy var indicatorView: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.layer.cornerRadius = config.indicatorCornerRadius
        object.layer.masksToBounds = true
        return object
    }()
    
    private lazy var alphaAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.isCumulative = false
        animation.autoreverses = false
        animation.timingFunction = .init(name: .default)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        animation.repeatCount = 1
        animation.duration = 0.17
        animation.fromValue = 1
        animation.toValue = 0
        return animation
    }()
    
    private override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    public init(config: SliderConfig) {
        self.config = config
        super.init(frame: .zero)
        setupUI()
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panProgess)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderDefaultIndicator {
    public func updateSlider() {
        progress = unitSize*CGFloat(multiplied)*100
    }
    
    public func addIndicator(_ indicator: UIView) {
        if !indicatorView.subviews.isEmpty {
            indicatorView.subviews.forEach{ $0.removeFromSuperview() }
        }
        indicatorView.backgroundColor = .clear
        indicatorView.layer.cornerRadius = 0
        indicatorView.addSubview(indicator)
        
        if config.direction == .horizontal {
            indicator.snp.makeConstraints { make in
                make.centerY.left.right.equalToSuperview()
            }
        } else {
            indicator.snp.makeConstraints { make in
                make.centerX.top.bottom.equalToSuperview()
            }
        }
    }
    
    public func showContent() {
        self.layer.removeAllAnimations()
        self.alpha = 1
    }
    
    public func hideContent() {
        self.layer.add(alphaAnimation, forKey: nil)
    }
}

extension SliderDefaultIndicator {
    private func setupUI() {
        self.addSubviews(extraView, sliderView, indicatorView)
        
        if config.direction == .horizontal {
            extraView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.width.equalTo(config.extraViewSize)
            }
            
            sliderView.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(config.extraViewSize)
                make.centerY.right.equalToSuperview()
                make.height.equalTo(config.sliderSize)
            }
            
            indicatorView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(config.indicatorSize)
            }
            indicatorOffset = NSLayoutConstraint(item: indicatorView, attribute: .left, relatedBy: .equal, toItem: sliderView, attribute: .left, multiplier: 1, constant: 0)
            indicatorOffset?.isActive = true
            
            self.sliderView.addSubviews(progressView)
            progressView.snp.makeConstraints { make in
                make.left.top.bottom.equalTo(sliderView)
                make.right.equalTo(indicatorView.snp.centerX)
            }
        } else {
            sliderView.snp.makeConstraints { make in
                make.centerX.top.bottom.equalToSuperview()
                make.width.equalTo(config.sliderSize)
            }
            
            indicatorView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(config.indicatorSize)
            }
            indicatorOffset = NSLayoutConstraint(item: indicatorView, attribute: .bottom, relatedBy: .equal, toItem: sliderView, attribute: .bottom, multiplier: 1, constant: 0)
            indicatorOffset?.isActive = true
            
            self.sliderView.addSubviews(progressView)
            progressView.snp.makeConstraints { make in
                make.left.right.bottom.equalTo(sliderView)
                make.top.equalTo(indicatorView.snp.centerY)
            }
        }
    }
}

extension SliderDefaultIndicator {
    @objc private func panProgess(_ sender: UIPanGestureRecognizer) {
        dragging = true
        switch sender.state {
        case .began:
            delegate?.sliderStartDragging(self)
        case .changed:
            if config.direction == .horizontal {
                let x = sender.translation(in: self).x
                if x + progress < 0 {
                    progress = 0
                } else if x + progress > unitSize * 100 {
                    progress = unitSize * 100
                } else {
                    progress += x
                }
            } else {
                let y = -sender.translation(in: self).y
                if y + progress < 0 {
                    progress = 0
                } else if y + progress > unitSize * 100 {
                    progress = unitSize * 100
                } else {
                    progress += y
                }
            }
            sender.setTranslation(.zero, in: self)
        case .ended:
            delegate?.sliderEndedDragging(self)
        default:
            break
        }
    }
}
