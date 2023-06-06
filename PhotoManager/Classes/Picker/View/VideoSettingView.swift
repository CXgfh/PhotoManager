//
//  VideoSettingView.swift
//  PhotoManager
//
//  Created by V on 2023/5/24.
//

import UIKit
import AVFoundation
import Util_V
import SnapKit
import SliderIndicator
import MediaEditorManager

class VideoSettingView: UIView {
    
    weak var delegate: VideoTailoringSliderIndicatorDelegate?
    
    var multiplied: Float = 0 {
        didSet {
            tailoringView.multiplied = multiplied
        }
    }
    
    var isNotChanged: Bool {
        return ppiSelect == 0
        && bpsSlider.multiplied == 1
        && fpsSlider.multiplied == 1
        && tailoringView.maxMultiplied == 1
        && tailoringView.minMultiplied == 0
    }
    
    private var isLandscape = true
    //分辨率
    private var ppi: CGSize = .zero
    
    //比特率
    private var bps: Float = 0
    private let minBPS: Float = 20000
    
    //帧率
    private var fps: Float = 0
    private let minFPS: Float = 24
    
    private var ppiSelect = 0
    private lazy var ppiStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        let label = UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        label.text = "分辨率:"
        stack.addArrangedSubview(label)
        
        for (key, value) in PhotoManagerPPI.allCases.enumerated() {
            let button = SelectButton()
            button.setTitle(value.title, for: .normal)
            button.tag = key
            button.isSelected = key == ppiSelect
            button.addTarget(self, action: #selector(ppiChanged), for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        return stack
    }()
    
    private lazy var bpsVauleLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        label.text = (bps*bpsSlider.multiplied).description
        label.isHidden = true
        return label
    }()
    
    private lazy var bpsSlider: SliderIndicatorView = {
        var config = SliderConfig.shared
        config.sliderColor = .black.withAlphaComponent(0.3)
        config.progressColor = .blue
        config.extraViewSize = 60
        
        let slider = SliderDefaultIndicator(config: config)
        slider.delegate = self
        
        let object = UIImageView()
        object.image = UIColor.blue.image(CGSize(width: config.indicatorSize, height: config.indicatorSize))
        object.layer.cornerRadius = config.indicatorSize/2
        object.layer.masksToBounds = true
        slider.addIndicator(object)
        
        let label = UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        label.text = "比特率:"
        slider.extraContentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return slider
    }()
    
   
    
    private lazy var fpsVauleLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        label.text = (fps*fpsSlider.multiplied).description
        label.isHidden = true
        return label
    }()
    
    private lazy var fpsSlider: SliderIndicatorView = {
        var config = SliderConfig.shared
        config.sliderColor = .black.withAlphaComponent(0.3)
        config.progressColor = .blue
        config.extraViewSize = 60
        
        let slider = SliderDefaultIndicator(config: config)
        slider.delegate = self
        
        let object = UIImageView()
        object.image = UIColor.blue.image(CGSize(width: config.indicatorSize, height: config.indicatorSize))
        object.layer.cornerRadius = config.indicatorSize/2
        object.layer.masksToBounds = true
        slider.addIndicator(object)
        
        let label = UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: .black)
        label.text = "帧率:"
        slider.extraContentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return slider
    }()
    
    private lazy var tailoringView: VideoTailoringSliderIndicator = {
        var config = VideoTailoringSliderConfig.shared
        
        let tailoring = VideoTailoringSliderIndicator(config: config)
        tailoring.delegate = self
        return tailoring
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoSettingView {
    @objc private func ppiChanged(_ sender: UIButton) {
        if ppiSelect != sender.tag {
            (ppiStackView.arrangedSubviews[ppiSelect] as? UIButton)?.isSelected = false
            ppiSelect = sender.tag
            (ppiStackView.arrangedSubviews[ppiSelect] as? UIButton)?.isSelected = true
        }
    }
}

extension VideoSettingView {
    func loadAVAsset(_ asset: AVAsset) {
        layoutIfNeeded()
        tailoringView.loadAVAsset(asset)
        if let track = asset.tracks(withMediaType: .video).first {
            bps = track.estimatedDataRate
            let trackSize = track.naturalSize.applying(track.preferredTransform)
            ppi = CGSize(width: abs(trackSize.width), height: abs(trackSize.height))
            isLandscape = ppi.width > ppi.height
            fps = track.nominalFrameRate
            bpsSlider.multiplied = 100
            fpsSlider.multiplied = 100
        } else {
            fatalError("加载错误")
        }
    }
    
    func getCompression() -> MediaEditorCompression {
        let newSize = ppiSelect == 0 ? ppi : PhotoManagerPPI.allCases[ppiSelect].size
        let widthKey = isLandscape ? newSize.width : newSize.height
        let heightKey = isLandscape ? newSize.height : newSize.width
        let bitRateKey = (bps-minBPS)*Float(bpsSlider.multiplied/100.0)+minBPS
        let frameRateKey = (fps-minFPS)*Float(fpsSlider.multiplied/100.0)+minFPS
        let videoSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: widthKey,
            AVVideoHeightKey: heightKey,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: bitRateKey,
                AVVideoExpectedSourceFrameRateKey: frameRateKey,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
             ] as [String : Any]
         ] as [String : Any]
        return MediaEditorCompression(audioMix: nil, videoSettings: videoSettings, audioSettings: nil)
    }
    
    func getTailoring() -> MediaEditorTailoring {
        return MediaEditorTailoring(star: tailoringView.minMultiplied, end: tailoringView.maxMultiplied)
    }
}

extension VideoSettingView {
    private func setupUI() {
        self.backgroundColor = .white
        self.addSubviews(ppiStackView,
                         bpsSlider,
                         bpsVauleLabel,
                         fpsSlider,
                         fpsVauleLabel,
                         tailoringView)
        
        ppiStackView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
        
        bpsSlider.snp.makeConstraints { make in
            make.top.equalTo(ppiStackView.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(36)
        }
        
        bpsVauleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(bpsSlider.snp.top)
            make.centerX.equalTo(bpsSlider.indicatorContentView)
        }
        
        fpsSlider.snp.makeConstraints { make in
            make.top.equalTo(bpsSlider.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(36)
            
        }
        
        fpsVauleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(fpsSlider.snp.top)
            make.centerX.equalTo(fpsSlider.indicatorContentView)
        }
        
        tailoringView.snp.makeConstraints { make in
            make.top.equalTo(fpsSlider.snp.bottom).offset(16)
            make.left.bottom.right.equalToSuperview().inset(16)
            make.height.equalTo(tailoringView.config.contentHeight)
        }
    }
}

extension VideoSettingView: SliderIndicatorDelegate {
    func sliderChanged(_ slider: SliderIndicator.SliderView, to newValue: Float) {
        if slider == fpsSlider {
            fpsVauleLabel.text = Int(newValue*(fps-minFPS)+minFPS).description
        } else {
            bpsVauleLabel.text = Int(newValue*(bps-minBPS)+minBPS).description
        }
    }
    
    func sliderStartDragging(_ slider: SliderIndicator.SliderView) {
        if slider == fpsSlider {
            fpsVauleLabel.isHidden = false
        } else {
            bpsVauleLabel.isHidden = false
        }
    }
    
    func sliderEndedDragging(_ slider: SliderIndicator.SliderView) {
        if slider == fpsSlider {
            fpsVauleLabel.isHidden = true
        } else {
            bpsVauleLabel.isHidden = true
        }
    }
}

extension VideoSettingView: VideoTailoringSliderIndicatorDelegate {
    func videoTailoringSliderStopPlayer() {
        delegate?.videoTailoringSliderStopPlayer?()
    }
    
    func videoTailoringSliderStartPlayer() {
        delegate?.videoTailoringSliderStartPlayer?()
    }
    
    func videoTailoringSliderCurrentTime(to newValue: Float) {
        delegate?.videoTailoringSliderCurrentTime?(to: newValue)
    }
    
    func videoTailoringSliderStartPlayer(at newValue: Float) {
        delegate?.videoTailoringSliderStartPlayer?(at: newValue)
    }
}
