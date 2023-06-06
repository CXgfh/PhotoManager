//
//  VerticalSliderIndicator.swift
//  SliderIndicator
//
//  Created by V on 2023/5/12.
//

import UIKit
import SnapKit
import Util_V

public class LevelSliderDefaultIndicator: UIView, SliderLevelIndicatorView {
    
    public var contentView: UIView {
        return self.sliderView
    }
    
    private var levelDic = [SliderLevel: UIImage]()
    
    private var level: SliderLevel = .zero {
        didSet {
            imageView.image = levelDic[level]
        }
    }

    public var delegate: SliderIndicatorDelegate?
    
    private let config: LevelSliderConfig
    
    private let unitSize: CGFloat
    
    private var indicatorOffset: NSLayoutConstraint?
    
    //是否正在拖拽
    private var dragging = false
    
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
    
    public lazy var sliderView: UIView = {
        let object = UIView()
        object.backgroundColor = config.sliderColor
        object.layer.cornerRadius = config.sliderCornerRadius
        object.layer.masksToBounds = true
        return object
    }()
    
    private lazy var progressView: UIView = {
        let object = UIView()
        object.backgroundColor = config.progressColor
        return object
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
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
    
    public init(config: LevelSliderConfig) {
        self.config = config
        if config.direction == .vertical {
            self.unitSize = config.sliderHeight/100.0
        } else {
            self.unitSize = config.sliderWidth/100.0
        }
        
        super.init(frame: .zero)
        setupUI()
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panProgess)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LevelSliderDefaultIndicator {
    public func setImage(_ image: UIImage?, _ state: SliderLevel) {
        levelDic[state] = image
        if state == level {
            imageView.image = image
        }
    }
    
    public func showContent() {
        self.sliderView.layer.removeAllAnimations()
        self.sliderView.alpha = 1
    }
    
    public func hideContent() {
        self.sliderView.layer.add(alphaAnimation, forKey: nil)
    }
}

extension LevelSliderDefaultIndicator {
    private func setupUI() {
        self.addSubview(sliderView)
        sliderView.snp.makeConstraints { make in
            make.width.equalTo(config.sliderWidth)
            make.height.equalTo(config.sliderHeight)
            make.center.equalToSuperview()
        }
        
        if config.direction == .vertical {
            sliderView.addSubviews(progressView, imageView)
            progressView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
            }
            
            indicatorOffset = NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: sliderView, attribute: .bottom, multiplier: 1, constant: 0)
            indicatorOffset?.priority = .defaultLow
            indicatorOffset?.isActive = true
            
            imageView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().inset(config.sliderCornerRadius)
                make.left.right.equalToSuperview()
            }
        } else {
            sliderView.addSubviews(progressView, imageView)
            progressView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
            }
            
            indicatorOffset = NSLayoutConstraint(item: progressView, attribute: .right, relatedBy: .equal, toItem: sliderView, attribute: .left, multiplier: 1, constant: 0)
            indicatorOffset?.priority = .defaultLow
            indicatorOffset?.isActive = true
            
            imageView.snp.makeConstraints { make in
                make.left.equalToSuperview().inset(config.sliderCornerRadius)
                make.top.bottom.equalToSuperview()
            }
        }
    }
}

extension LevelSliderDefaultIndicator {
    @objc func panProgess(_ sender: UIPanGestureRecognizer) {
        dragging = true
        switch sender.state {
        case .began:
            delegate?.sliderStartDragging(self)
        case .changed:
            if config.direction == .vertical {
                let y = -sender.translation(in: self).y
                if progress + y < 0 {
                    progress = 0
                } else if progress + y > unitSize * 100 {
                    progress = unitSize * 100
                } else {
                    progress += y
                }
            } else {
                let x = sender.translation(in: self).x
                if x + progress < 0 {
                    progress = 0
                } else if x + progress > unitSize * 100 {
                    progress = unitSize * 100
                } else {
                    progress += x
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
