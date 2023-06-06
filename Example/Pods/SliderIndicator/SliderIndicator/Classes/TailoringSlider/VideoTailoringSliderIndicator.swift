//
//  VideoTailoringIndicatorView.swift
//  PhotoManager
//
//  Created by Vick on 2022/10/14.
//

import UIKit
import Util_V
import Photos
import SnapKit

@objc public protocol VideoTailoringSliderIndicatorDelegate: AnyObject {
    @objc optional func videoTailoringSliderStopPlayer()
    @objc optional func videoTailoringSliderStartPlayer()
    @objc optional func videoTailoringSliderStartPlayer(at newValue: Float)
    @objc optional func videoTailoringSliderCurrentTime(to newValue: Float)
}

public class VideoTailoringSliderIndicator: UIView {
    
    private weak var asset: AVAsset?
    
    public weak var delegate: VideoTailoringSliderIndicatorDelegate?
    
    public private(set) var config: VideoTailoringSliderConfig = .shared
    
    private var duration: Double = .zero //总时长
    
    private var dragging = false  //是否正在拖拽
    
    private var isPlaying = false {
        didSet {
            playButton.setImage(isPlaying ? UIImage(tailoring: "SliderIndicator_pause") : UIImage(tailoring: "SliderIndicator_play"), for: .normal)
        }
    }
    
    private var unitWidth: CGFloat {
        layoutIfNeeded()
        return (self.imageContentView.width - config.indicatorWidth)/100.0
    }
    
    //左裁剪比例
    public var minMultiplied: Float {
        return Float((leftLayout?.constant ?? 0)/unitWidth/100.0)
    }
    
    //当前进度比例
    public var multiplied: Float = 0 {
        didSet {
            if oldValue != multiplied {
                dragging = false
                var correction = multiplied
                if correction < minMultiplied {
                    correction = minMultiplied
                } else if correction > maxMultiplied {
                    correction = maxMultiplied
                    delegate?.videoTailoringSliderStopPlayer?()
                    isPlaying = false
                }
                progressX = unitWidth*CGFloat(correction)*100
                currentTimeLabel.text = (duration*Double(correction)).mediaTime
            }
        }
    }
    
    //右裁剪比例
    public var maxMultiplied: Float {
        return Float((imageContentView.width - config.indicatorWidth + (rightLayout?.constant ?? 0))/unitWidth/100.0)
    }
    
    //图片尺寸
    private var targetSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: imageContentView.width/CGFloat(config.imagesCount), height: config.contentHeight-6)
    }
    
    //MAKR: -- UI --
    private lazy var contentView: UIView = {
        let object = UIView()
        object.backgroundColor = config.contentColor
        return object
    }()
    
    //MARK: -基础UI
    private lazy var lineView: UIView = {
        let object = UIView()
        object.backgroundColor = config.lineColor
        return object
    }()
    
    private lazy var imageContentView: UIView = {//V_V优化可滚动
        let object = UIView()
        object.backgroundColor = .white.withAlphaComponent(0.5)
        return object
    }()
    
    private lazy var imageViews: [UIImageView] = { //V_V优化
        var vs = [UIImageView]()
        let size = targetSize
        for i in 0..<config.imagesCount {
            let v = UIImageView(frame: CGRect(x: CGFloat(i)*size.width, y: 0, width: size.width, height: size.height))
            v.clipsToBounds = true
            imageContentView.addSubview(v)
            vs.append(v)
        }
        return vs
    }()
    
    //MARK: ---裁剪UI
    private var leftLayout: NSLayoutConstraint?
    private lazy var leftCutView: UIView = {
        let object = UIView()
        object.backgroundColor = config.cutColor
        object.tag = 1
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panHandrail)))
        return object
    }()
    
    private var rightLayout: NSLayoutConstraint?
    private lazy var rightCutView: UIView = {
        let object = UIView()
        object.backgroundColor = config.cutColor
        object.tag = 2
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panHandrail)))
        return object
    }()
    
    private lazy var leftDimmingView: UIView = {
        let object = UIView()
        object.backgroundColor = config.contentColor.withAlphaComponent(0.3)
        return object
    }()
    
    private lazy var rightDimmingView: UIView = {
        let object = UIView()
        object.backgroundColor = config.contentColor.withAlphaComponent(0.3)
        return object
    }()
    
    private lazy var topDimmingView: UIView = {
        let object = UIView()
        object.backgroundColor = config.cutColor
        return object
    }()
    
    private lazy var bottomDimmingView: UIView = {
        let object = UIView()
        object.backgroundColor = config.cutColor
        return object
    }()
    
    //MARK: -播放UI
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(tailoring: "SliderIndicator_play"), for: .normal)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(playTap), for: .touchUpInside)
        return button
    }()
    
    //辅助控制
    private lazy var auxiliaryView: UIView = {
        let object = UIView()
        object.backgroundColor = .clear
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panProgess)))
        return object
    }()

    private var progressX: CGFloat = 0 {
        didSet {
            if oldValue != progressX {
                indicatorLeft?.constant = progressX
                if dragging, progressX != oldValue {
                    let newValue = progressX/unitWidth/100.0
                    multiplied = Float(newValue)
                    currentTimeLabel.text = (duration*newValue).mediaTime
                    delegate?.videoTailoringSliderCurrentTime?(to: multiplied)
                }
            }
        }
    }
    private var indicatorLeft: NSLayoutConstraint?
    private lazy var indicatorView: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.layer.masksToBounds = true
        object.isUserInteractionEnabled = true
        object.layer.cornerRadius = config.indicatorWidth/2
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panProgess)))
        return object
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = config.contentColor
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    public init(config: VideoTailoringSliderConfig) {
        super.init(frame: .zero)
        self.config = config
        setupUI()
    }
    
    private override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoTailoringSliderIndicator {
    public func loadAVAsset(_ asset: AVAsset) {
        self.asset = asset
        self.duration = asset.duration.seconds
        loadImages()
    }
    
    private func loadImages() {
        guard let asset = self.asset else { return }
        let star: Double = 0
        let end: Double = 0
        let increment = (duration-star-end)/Double(config.imagesCount)
        var times = [CMTime]()
        for i in 0..<config.imagesCount {
            times.append(CMTimeMakeWithSeconds(Double(i)*increment+star, preferredTimescale: 600))
        }
        
        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
            let genertor = AVAssetImageGenerator(asset: asset)
            genertor.appliesPreferredTrackTransform = true
            genertor.requestedTimeToleranceAfter = .zero
            genertor.requestedTimeToleranceBefore = .zero
            for index in times.indices {
                var actualTime = CMTimeMake(value: 0, timescale: 0)
                let cgImage = try? genertor.copyCGImage(at: times[index], actualTime: &actualTime)
                if let cgImage = cgImage {
                    DispatchQueue.main.async {
                        self.imageViews[index].image = UIImage(cgImage: cgImage)
                    }
                }
            }
        }
    }
}

extension VideoTailoringSliderIndicator {
    private func setupUI() {
        self.backgroundColor = .clear
        self.addSubviews(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(config.contentHeight)
        }
        
        self.contentView.addSubviews(lineView, imageContentView)
        lineView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(config.contentHeight)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(1)
        }

        imageContentView.snp.makeConstraints { make in
            make.left.equalTo(lineView.snp.right).offset(config.cutWidth)
            make.top.bottom.equalToSuperview().inset(3)
            make.right.equalToSuperview().inset(config.cutWidth)
        }

        addCutControl()
        addPlayControl()
    }
    
    private func addCutControl() {
        self.addSubviews(leftCutView,
                         rightCutView,
                         topDimmingView,
                         bottomDimmingView,
                         leftDimmingView,
                         rightDimmingView)
        
        leftLayout = NSLayoutConstraint(item: leftCutView, attribute: .right, relatedBy: .equal, toItem: imageContentView, attribute: .left, multiplier: 1, constant: 0)
        leftLayout?.isActive = true
        leftCutView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.width.equalTo(config.cutWidth)
        }
        
        rightLayout = NSLayoutConstraint(item: rightCutView, attribute: .left, relatedBy: .equal, toItem: imageContentView, attribute: .right, multiplier: 1, constant: 0)
        rightLayout?.isActive = true
        rightCutView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.width.equalTo(config.cutWidth)
        }
        
        topDimmingView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.bottom.equalTo(imageContentView.snp.top)
            make.left.equalTo(leftCutView.snp.right)
            make.right.equalTo(rightCutView.snp.left)
        }
        
        bottomDimmingView.snp.makeConstraints { make in
            make.top.equalTo(imageContentView.snp.bottom)
            make.bottom.equalTo(contentView)
            make.left.equalTo(leftCutView.snp.right)
            make.right.equalTo(rightCutView.snp.left)
        }
        
        leftDimmingView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(imageContentView)
            make.right.equalTo(leftCutView.snp.left).priority(750)
        }

        rightDimmingView.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(imageContentView)
            make.left.equalTo(rightCutView.snp.right).priority(750)
        }
    }
    
    private func addPlayControl() {
        self.addSubviews(playButton,
                         auxiliaryView,
                         indicatorView,
                         currentTimeLabel)
        playButton.snp.makeConstraints { make in
            make.left.top.equalTo(contentView)
            make.width.height.equalTo(config.contentHeight)
        }
        
        auxiliaryView.snp.makeConstraints { make in
            make.top.bottom.equalTo(imageContentView)
            make.left.equalTo(leftCutView.snp.right)
            make.right.equalTo(rightCutView.snp.left)
        }
        
        indicatorLeft = NSLayoutConstraint(item: indicatorView, attribute: .left, relatedBy: .equal, toItem: imageContentView, attribute: .left, multiplier: 1, constant: 0)
        indicatorLeft?.isActive = true
        indicatorView.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.width.equalTo(config.indicatorWidth)
        }
        
        
        currentTimeLabel.snp.makeConstraints { make in
            make.bottom.equalTo(indicatorView.snp.top).offset(-4)
            make.centerX.equalTo(indicatorView)
        }
    }
    
    public func addIndicator(_ indicator: UIView) {
        if !indicatorView.subviews.isEmpty {
            indicatorView.subviews.forEach{ $0.removeFromSuperview() }
        }
        indicatorView.backgroundColor = .clear
        indicatorView.layer.cornerRadius = 0
        indicatorView.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.centerY.left.right.equalToSuperview()
        }
    }
}

extension VideoTailoringSliderIndicator {
    @objc private func playTap() {
        isPlaying = !isPlaying
        if isPlaying {
            if multiplied < maxMultiplied {
                delegate?.videoTailoringSliderStartPlayer?(at: multiplied)
            } else {
                delegate?.videoTailoringSliderStartPlayer?(at: minMultiplied)
            }
        } else {
            delegate?.videoTailoringSliderStopPlayer?()
        }
    }
    
    @objc private func panHandrail(_ sender: UIPanGestureRecognizer) {
        dragging = true
        delegate?.videoTailoringSliderStopPlayer?()
        isPlaying = false
        switch sender.state {
        case .changed:
            let point = sender.translation(in: contentView)
            sender.setTranslation(.zero, in: contentView)
            let tag = sender.view?.tag
            switch tag {
            case 1:
                if let left = leftLayout?.constant, let right = rightLayout?.constant {
                    if left + point.x < 0 {
                        leftLayout?.constant = 0
                    } else if left - right + config.minWidth + point.x > imageContentView.width {
                        leftLayout?.constant = imageContentView.width - config.minWidth + right
                        changedIndicatorLeft()
                    } else {
                        leftLayout?.constant = left + point.x
                        changedIndicatorLeft()
                    }
                }
            case 2:
                if let left = leftLayout?.constant, let right = rightLayout?.constant {
                    if right + point.x > 0 {
                        rightLayout?.constant = 0
                    } else if left - right + config.minWidth - point.x > imageContentView.width {
                        rightLayout?.constant = left + config.minWidth - imageContentView.width
                        changedIndicatorRight()
                    } else {
                        rightLayout?.constant = right + point.x
                        changedIndicatorRight()
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    private func changedIndicatorLeft() {
        if let left = leftLayout?.constant, let indicator = indicatorLeft?.constant {
            if left > indicator {
                progressX = left
            }
        }
    }
    
    private func changedIndicatorRight() {
        if let right = rightLayout?.constant, let indicator = indicatorLeft?.constant {
            if imageContentView.width + right - config.indicatorWidth < indicator {
                progressX = imageContentView.width + right - config.indicatorWidth
            }
        }
    }
    
    @objc private func panProgess(_ sender: UIPanGestureRecognizer) {
        dragging = true
        switch sender.state {
        case .began:
            delegate?.videoTailoringSliderStopPlayer?()
            isPlaying = false
        case .changed:
            let x = sender.translation(in: contentView).x
            if x + progressX < 0 {
                progressX = 0
            } else if x + progressX > unitWidth * 100 {
                progressX = unitWidth * 100
            } else {
                progressX += x
            }
            sender.setTranslation(.zero, in: contentView)
        case .ended:
            break
        default:
            break
        }
    }
}

