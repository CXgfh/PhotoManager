//
//  VideoDetailViewController.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/30.
//

import UIKit
import Util_V
import Photos
import AVKit
import SliderIndicator
import SnapKit
import ContentSizeView
import MediaPlayer

enum PlayState {
    case none
    case stop
    case playing
    case playEnd
}

enum SpeedQuantity: Float, CaseIterable, NormalPopoverOption {
    case minimum = 0.25
    case half = 0.5
    case normal = 1
    case quicker = 1.25
    case faster = 1.5
    case more = 1.75
    case maximum = 2
    
    var title: String {
        switch self {
        case .minimum:
            return "0.25倍"
        case .half:
            return "0.5倍"
        case .normal:
            return "1倍"
        case .quicker:
            return "1.25倍"
        case .faster:
            return "1.5倍"
        case .more:
            return "1.75倍"
        case .maximum:
            return "2倍"
        }
    }
}

class VideoDetailViewController: UIViewController {
    
    private let asset: PHAsset
    
    private var state: PlayState = .none {
        didSet {
            if state != oldValue {
                if isDragging {
                    return
                }
                if state == .playEnd {
                    isLock = false
                    lockButton.setImage(UIImage(photo: "picker_lock.open"), for: .normal)
                    PhotoManager.sharde.delegate.call {
                        $0.photoManagerUnlockTheScreen?()
                    }
                }
                needToShowControl = true
                playButton.setImage(state == .playing ? UIImage(photo: "picker_pause") : UIImage(photo: "picker_play"), for: .normal)
            }
        }
    }
    
    private var needToShowControl = false {
        didSet {
            contronTimer?.invalidate()
            if isLock {
                lockButton.isHidden = !needToShowControl
            } else {
                if state == .playEnd {
                    lockButton.isHidden = true
                } else {
                    lockButton.isHidden = !needToShowControl
                }
                rotateButton.isHidden = !needToShowControl
                bottomControl.isHidden = !needToShowControl
                navigationController?.isNavigationBarHidden = !needToShowControl
            }
            starTimer()
        }
    }
    
    //用户正在拖动底部进度条
    private var isDragging = false
    
    private var contronTimer: Timer?
    
    private var currentTime: TimeInterval = .zero {
        didSet {
            let text = currentTime.mediaTime + "/" + totalTime.mediaTime
            timeLabel.text = text
            centerTimeLabel.text = text
        }
    }
    
    private var totalTime: TimeInterval = .zero
    
    //MARK: -- 旋转屏幕 ---
    private var isPortrait = true {
        didSet {
            rotateButton.setImage(isPortrait ? UIImage(photo: "picker_iphone.gen2") : UIImage(photo: "picker_iphone.gen2.landscape"), for: .normal)
        }
    }
    private lazy var rotateButton: UIButton = {
        let button = UIButton(image: UIImage(photo: "picker_iphone.gen2"))
        button.addTarget(self, action: #selector(rotateTap), for: .touchUpInside)
        return button
    }()
    
    //MARK: --- 锁定 ----
    private var isLock = false
    private lazy var lockButton: UIButton = {
        let button = UIButton(image: UIImage(photo: "picker_lock.open"))
        button.addTarget(self, action: #selector(lockTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var volumeView: SliderView = {
        var config = LevelSliderConfig.shared
        let slider = LevelSliderDefaultIndicator(config: config)
        for index in SliderLevel.allCases {
            slider.setImage(UIColor.random.image(CGSize(width: 10, height: 10)), index)
        }
        slider.contentView.alpha = 0
        slider.multiplied = session.outputVolume
        slider.delegate = self
        return slider
    }()
    
    private lazy var brightnessView: SliderView = {
        var config = LevelSliderConfig.shared
        let slider = LevelSliderDefaultIndicator(config: config)
        for index in SliderLevel.allCases {
            slider.setImage(UIColor.random.image(CGSize(width: 10, height: 10)), index)
        }
        slider.contentView.alpha = 0
        slider.multiplied = Float(UIScreen.main.brightness)
        slider.delegate = self
        return slider
    }()
    
    //MARK: ---中心控制播放控制 ---
    private lazy var centerControl: UIView = {
        let object = UIView()
        
        let singlgeTap = UITapGestureRecognizer(target: self, action: #selector(singleClick))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleTap.numberOfTapsRequired = 2
        singlgeTap.require(toFail: doubleTap)
        
        view.addGestureRecognizer(singlgeTap)
        view.addGestureRecognizer(doubleTap)
        
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panTap)))
        return object
    }()
    
    private lazy var centerTimeLabel: ContentSizeOfLabel = {
        let label = ContentSizeOfLabel(font: .systemFont(ofSize: 17, weight: .regular), textColor: .white)
        label.titleEdgeInsets = .init(top: 5, left: 8, bottom: 5, right: 8)
        label.maxCornerRadius = 4
        label.backgroundColor = .black.withAlphaComponent(0.3)
        label.isHidden = true
        label.isUserInteractionEnabled = false
        return label
    }()
    
    //MARK: -- 底部控制播放控制 --
    private var bottomControl: UIView = UIView()
    
    private lazy var playButton: UIButton = {
        let button = UIButton(image: UIImage(photo: "picker_play"))
        button.addTarget(self, action: #selector(playTap), for: .touchUpInside)
        return button
    }()

    private lazy var playSlider: SliderIndicatorView = {
        var config = SliderConfig.shared
        config.sliderColor = .white
        config.progressColor = .blue
        
        let slider = SliderDefaultIndicator(config: config)
        slider.delegate = self
        
        let object = UIImageView()
        object.image = UIColor.blue.image(CGSize(width: config.indicatorSize, height: config.indicatorSize))
        object.layer.cornerRadius = config.indicatorSize/2
        object.layer.masksToBounds = true
        slider.addIndicator(object)
        return slider
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 10, weight: .regular), textColor: .white)
        label.text = "00:00/00:00"
        return label
    }()
    
    //MARK: --导航栏--
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_return"), for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var speedButton: UIButton = {
        let button = UIButton(image: UIImage(photo: "picker_ellipsis"))
        button.addTarget(self, action: #selector(speedTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let activity = UIActivityIndicatorView(style: style)
        activity.color = .black
        activity.hidesWhenStopped = true
        return activity
    }()
    
    //MARK: -- 播放器 --
    private var timeObserver: Any?
    private var layer: AVPlayerLayer?
    private var myPlayer: AVPlayer?
    private let session = AVAudioSession.sharedInstance()
    private var volume: UISlider?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        starLoading()
        setAudioSession()
        setVolume()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        UIView.animate(withDuration: coordinator.transitionDuration) {
            self.layer?.frame.size = size
        } completion: { _ in
            self.playSlider.updateSlider()
            self.isPortrait = size.width < size.height
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePlayerObserver()
        if state == .playing {
            myPlayer?.pause()
            state = .stop
        }
        navigationBar.changedTranslucent(isTranslucent: false)
        PhotoManager.sharde.delegate.call {
            $0.photoManagerUnlockTheScreen?()
        }
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPlayerObserver()
        navigationBar.changedTranslucent(isTranslucent: true)
        if isLock {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerLockTheScreen?()
            }
        } else {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerUnlockTheScreen?()
            }
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
    
    init(asset: PHAsset) {
        self.asset = asset
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        myPlayer = nil
    }
}

extension VideoDetailViewController {
    @objc private func backTap() {
        if !isPortrait {
            if #available(iOS 16, *),
               let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                scenes.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                setNeedsUpdateOfSupportedInterfaceOrientations()
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func volumeChanged() {
        if let value = volume?.value {
            if value != volumeView.multiplied {
                volumeView.showContent()
                volumeView.multiplied = value
            }
        }
    }
    
    @objc private func rotateTap() {
        if #available(iOS 16, *),
           let scenes = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if isPortrait {
                scenes.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                setNeedsUpdateOfSupportedInterfaceOrientations()
                isPortrait = false
            } else {
                scenes.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
                setNeedsUpdateOfSupportedInterfaceOrientations()
                isPortrait = true
            }
        } else {
            if isPortrait {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
                isPortrait = false
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
                isPortrait = true
            }
        }
    }
    
    @objc private func lockTap() {
        contronTimer?.invalidate()
        isLock = !isLock
        lockButton.setImage(isLock ? UIImage(photo: "picker_lock") : UIImage(photo: "picker_lock.open"), for: .normal)
        rotateButton.isHidden = isLock
        bottomControl.isHidden = isLock
        navigationController?.isNavigationBarHidden = isLock
        if isLock {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerLockTheScreen?()
            }
        } else {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerUnlockTheScreen?()
            }
        }
        starTimer()
    }
    
    @objc private func speedTap() {
        let popover = NormalPopoverViewController<SpeedQuantity>(single: SpeedQuantity.allCases)
        popover.popoverPresentationController?.permittedArrowDirections = [.up]
        popover.popoverPresentationController?.sourceView = speedButton
        popover.popoverPresentationController?.sourceRect = CGRect(x: self.speedButton.frame.midX, y: self.speedButton.frame.maxY, width: 10, height: 10)
        popover.single = { result in
            self.activity.startAnimating()
            self.myPlayer?.rate = result.rawValue
        }
        self.present(popover, animated: true)
    }
    
    @objc private func playTap() {
        guard !isLock else { return }
        switch state {
        case .playing:
            state = .stop
            self.myPlayer?.pause()
        case .stop:
            state = .playing
            self.myPlayer?.play()
        case .playEnd:
            state = .playing
            playChanged(0) { _ in
                self.myPlayer?.play()
            }
        case .none:
            debugPrint("媒体加载失败")
        }
    }
    
    @objc private func doubleClick(_ tap: UITapGestureRecognizer) {
        playTap()
    }
    
    @objc private func singleClick(_ tap: UITapGestureRecognizer) {
        needToShowControl = !needToShowControl
    }
    
    @objc private func panTap(_ sender: UIPanGestureRecognizer) {
        guard !isLock else { return }
        switch sender.state {
        case .began:
            guard state != .none else { return }
            isDragging = true
            centerTimeLabel.isHidden = false
        case .changed:
            let point = sender.translation(in: view)
            sender.setTranslation(.zero, in: view)
            guard state != .none else { return }
            if state == .playing {
                state = .stop
                myPlayer?.pause()
            }
            
            let offset = point.x / 10
            if currentTime + offset > 0 {
                if currentTime + offset < totalTime {
                    currentTime += offset
                } else {
                    currentTime = totalTime
                }
            } else {
                currentTime = 0
            }
            playSlider.multiplied = Float(currentTime/totalTime)
            playChanged(currentTime) { _ in }
        case .ended:
            guard state != .none else { return }
            centerTimeLabel.isHidden = true
            if currentTime < totalTime {
                state = .playing
                myPlayer?.play()
                isDragging = false
            } else {
                isDragging = false
                state = .playEnd
            }
        default:
            break
        }
    }
    
    private func starTimer() {
        guard !isDragging else { return } //用户未操作
        guard state == .playing else { return } //播放中
        guard needToShowControl else { return } //控制视图展示中
        
        contronTimer = .scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(endTimer), userInfo: nil, repeats: false)
    }
    
    @objc private func endTimer() {
        contronTimer?.invalidate()
        guard !isDragging else { return }
        guard state == .playing else { return }
        needToShowControl = false
    }
}

extension VideoDetailViewController {
    private func setupUI() {
        self.view.backgroundColor = .black
        view.backgroundColor = UIColor(photo: "picker_theme_color")
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        title = "详情"
        navigationItem.rightBarButtonItem = .init(customView: speedButton)
        
        self.view.addSubview(activity)
        activity.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        isPortrait = UIApplication.shared.statusBarOrientation == .portrait
    }
    
    private func starLoading() {
        activity.startAnimating()
        asset.getVideo { av, info in
            self.activity.stopAnimating()
            if let av = av {
                self.totalTime = av.duration.seconds
                let item = AVPlayerItem(asset: av)
                self.myPlayer = AVPlayer(playerItem: item)
                self.myPlayer?.isMuted = false
                self.layer = AVPlayerLayer(player: self.myPlayer)
                self.layer?.videoGravity = .resizeAspect
                self.layer?.backgroundColor = UIColor.black.cgColor
                self.layer?.frame = self.view.frame
                self.view.layer.addSublayer(self.layer!)
                self.addControl()
                self.addPlayerObserver()
                self.state = .playing
                self.myPlayer?.play()
            }
        }
    }
    
    private func addControl() {
        self.view.addSubviews(bottomControl, volumeView, brightnessView, centerControl, lockButton, rotateButton)
        bottomControl.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        volumeView.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(200)
            make.width.equalTo(50)
            make.centerY.equalToSuperview()
        }
        
        brightnessView.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(50)
            make.height.equalTo(200)
            make.centerY.equalToSuperview()
        }
        
        centerControl.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.right.equalTo(view.safeAreaLayoutGuide).offset(-50)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(bottomControl.snp.top)
        }
        
        bottomControl.addSubviews(playButton, playSlider, timeLabel)
        playButton.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(30)
        }
        
        playSlider.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(playButton.snp.right).offset(8)
            make.right.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalTo(playSlider)
        }
        
        centerControl.addSubview(centerTimeLabel)
        centerTimeLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
        }
        
        lockButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.left.equalTo(bottomControl.snp.left)
        }
        
        rotateButton.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.right.equalTo(bottomControl.snp.right)
        }
    }
    
    private func setAudioSession() {
        do {
            try session.setCategory(.playback) //开启静音播放
            try session.setActive(true)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    private func setVolume() {
        let system = MPVolumeView(frame: CGRect(x: -100, y: 0, width: 10, height: 10))
        view.addSubview(system)
        for subView in system.subviews {
            if subView.isKind(of: UISlider.self) {
                volume = subView as? UISlider
                volume?.addTarget(self, action: #selector(volumeChanged), for: .valueChanged)
            }
        }
    }
}

extension VideoDetailViewController {
    func playChanged(_ star: Double, completionHandler: @escaping (Bool) -> Void) {
        let time = CMTimeMake(value: Int64(star*600), timescale: 600)
        myPlayer?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completionHandler)
    }
    
    func addPlayerObserver() {
        if timeObserver == nil {
            timeObserver =  myPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0/60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { time in
                if self.myPlayer?.currentItem?.status == .readyToPlay {
                    if let duration = self.myPlayer?.currentItem?.duration {
                        if time >= duration {
                            self.myPlayer?.pause()
                            self.state = .playEnd
                        }
                        self.currentTime = time.seconds
                        self.playSlider.multiplied = Float(time.multipliedBy(duration))
                    } else {
                        self.myPlayer?.pause()
                        self.state = .playEnd
                    }
                }
            })
        }
    }
    
    func removePlayerObserver() {
        if let observer = timeObserver {
            myPlayer?.removeTimeObserver(observer)
            timeObserver = nil
        }
        contronTimer?.invalidate()
    }
}

extension VideoDetailViewController: SliderIndicatorDelegate {
    func sliderChanged(_ slider: SliderIndicator.SliderView, to newValue: Float) {
        if slider == playSlider {
            if let seconds = myPlayer?.currentItem?.duration.seconds {
                playChanged(seconds*Double(newValue)) { _ in }
            }
        } else if slider == volumeView {
            volume?.value = newValue
        } else if slider == brightnessView {
            UIScreen.main.brightness = CGFloat(newValue)
        }
    }
    
    func sliderStartDragging(_ slider: SliderIndicator.SliderView) {
        if slider == playSlider {
            isDragging = true
            myPlayer?.pause()
        } else {
            slider.showContent()
        }
    }
    
    func sliderEndedDragging(_ slider: SliderIndicator.SliderView) {
        if slider == playSlider {
            isDragging = false
            myPlayer?.play()
        } else {
            slider.hideContent()
        }
    }
}
