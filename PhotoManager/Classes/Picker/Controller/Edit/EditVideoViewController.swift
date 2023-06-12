//
//  VideoTailoringViewController.swift
//  PhotoManager
//
//  Created by Vick on 2022/10/12.
//

import UIKit
import Util_V
import Photos
import SliderIndicator
import MediaEditorManager

class EditVideoViewController: UIViewController {
    
    var confirm: ((_ url: URL?)->Void)?
    
    private var asset: AVAsset?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_return"), for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(photo: "picker_text_color"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitle("确认", for: .normal)
        button.addTarget(self, action: #selector(confirmTap), for: .touchUpInside)
        return button
    }()
    
    private var timeObserver: Any?
    private var layer: AVPlayerLayer?
    private var myPlayer: AVPlayer?
    
    private lazy var playView = UIView()
    
    private lazy var settingView: VideoSettingView = {
        let setting = VideoSettingView()
        setting.delegate = self
        return setting
    }()
    
    private lazy var manager = MediaDataEditorManager()
    
    private lazy var activityView: UIView = {
        let object = UIView()
        object.addSubviews(progressView, progressLabel)
        progressView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
            make.width.height.equalTo(80)
        }
        
        progressLabel.snp.makeConstraints { make in
            make.center.equalTo(progressView)
        }
        object.isHidden = true
        return object
    }()
    
    private var isActivity = false
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 10, weight: .regular), textColor: .white)
        return label
    }()
    
    private lazy var progressView: ProgressLoopView = {
        let progress = ProgressLoopView()
        return progress
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
        activity.startAnimating()
        return activity
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removePlayerObserver()
        PhotoManager.sharde.delegate.call {
            $0.photoManagerUnlockTheScreen?()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPlayerObserver()
        PhotoManager.sharde.delegate.call {
            $0.photoManagerSpecifiedScreen?(.portrait)
        }
    }

    init(phAsset: PHAsset) {
        super.init(nibName: nil, bundle: nil)
        activity.startAnimating()
        phAsset.getVideo { av, info in
            self.asset = av
            self.loadAVAsset()
        }
    }
    
    init(avAsset: AVAsset?) {
        super.init(nibName: nil, bundle: nil)
        self.asset = avAsset
        self.loadAVAsset()
    }
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.asset = AVAsset(url: url)
        self.loadAVAsset()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditVideoViewController {
    @objc private func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func confirmTap() {
        if isActivity {
            return
        }
        if let asset = asset {
            isActivity = true
            self.activityView.isHidden = false
            debugPrint("开始编辑")
            if settingView.isNotChanged {
                self.activityView.isHidden = true
                self.isActivity = false
                let url = (asset as? AVURLAsset)?.url
                self.confirm?(url)
            } else {
                let water = MediaEditorWaterMaker(image: UIImage(photo: "picker_choose"), centerOffsetX: 0, centerOffsetY: 0, star: .zero, duration: 20)
                manager.edit(at: asset,
                                  tailoring: settingView.getTailoring(),
                                  compression: settingView.getCompression(),
                                  waterMakers: [water],
                                  progress: { value in
                    DispatchQueue.main.async {
                        self.progressView.progress = value
                        self.progressLabel.text = String(format: "%.2f", value*100) + "%"
                    }
                }, complete: { result in
                    DispatchQueue.main.async {
                        self.activityView.isHidden = true
                        self.isActivity = false
                        switch result {
                        case .success(let url):
                            self.confirm?(url)
                            #if DEBUG
                            if let url = url {
                                PhotoManager.sharde.saveVideo(at: url)
                            }
                            #endif
                        case .failure(let error):
                            debugPrint(error)
                            self.confirm?(nil)
                        }
                    }
                })
            }
        } else {
            debugPrint("视频未加载")
        }
        
        
    }
}

extension EditVideoViewController {
    private func setupUI() {
        view.backgroundColor = UIColor(photo: "picker_theme_color")
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        title = "编辑"
        navigationItem.rightBarButtonItem = .init(customView: confirmButton)
        
        self.view.addSubviews(playView,
                              settingView,
                              activity)
        playView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(settingView.snp.top)
        }
        
        settingView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        activity.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func loadAVAsset() {
        self.activity.stopAnimating()
        self.view.layoutIfNeeded()
        if let asset = asset {
            self.settingView.loadAVAsset(asset)
            let item = AVPlayerItem(asset: asset)
            self.myPlayer = AVPlayer(playerItem: item)
            self.myPlayer?.isMuted = false
            self.layer = AVPlayerLayer(player: self.myPlayer)
            self.layer?.videoGravity = .resizeAspect
            self.layer?.backgroundColor = UIColor.black.cgColor
            self.layer?.frame = self.playView.frame
            self.view.layer.addSublayer(self.layer!)
            self.addPlayerObserver()
            
            self.view.addSubview(self.activityView)
            self.activityView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}

extension EditVideoViewController {
    func playChanged(_ star: Double, completionHandler: @escaping (Bool) -> Void) {
        let time = CMTimeMake(value: Int64(star*600), timescale: 600)
        myPlayer?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: completionHandler)
    }
    
    func addPlayerObserver() {
        if timeObserver == nil {
            timeObserver = myPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1.0/60.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main, using: { (time) in
                if self.myPlayer?.currentItem?.status == .readyToPlay {
                    if let duration = self.myPlayer?.currentItem?.duration {
                        if time >= duration {
                            self.myPlayer?.pause()
                        }
                        self.settingView.multiplied = Float(time.multipliedBy(duration))
                    } else {
                        self.myPlayer?.pause()
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
    }
}

extension EditVideoViewController: VideoTailoringSliderIndicatorDelegate {
    func videoTailoringSliderStopPlayer() {
        myPlayer?.pause()
    }
    
    func videoTailoringSliderStartPlayer() {
        myPlayer?.play()
    }
    
    func videoTailoringSliderCurrentTime(to newValue: Float) {
        if let seconds = myPlayer?.currentItem?.duration.seconds {
            playChanged(Double(newValue)*seconds) { _ in }
        }
    }
    
    func videoTailoringSliderStartPlayer(at newValue: Float) {
        if let seconds = myPlayer?.currentItem?.duration.seconds {
            playChanged(Double(newValue)*seconds) { _ in
                self.myPlayer?.play()
            }
        }
    }
}
