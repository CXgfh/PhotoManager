//
//  CustomSession.swift
//  PhotoManager
//
//  Created by V on 2023/6/6.
//

import UIKit
import AVFoundation

class CustomCaptureSession: NSObject {

    var position = AVCaptureDevice.Position.back {
        didSet {
            if position != oldValue {
                stopCapture()
                removeInputs()
                setInputs()
                starCapture()
            }
        }
    }
    
    //MARK: ------ 参数设置 -----
    lazy var videoSetting: [String : Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: videoWidth,
        AVVideoHeightKey: videoHeight,
        AVVideoCompressionPropertiesKey: [
            AVVideoExpectedSourceFrameRateKey: 30,
            AVVideoMaxKeyFrameIntervalKey: 1,
            AVVideoAverageBitRateKey: videoWidth*videoHeight*4
        ]
    ]

    let audioSetting: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 1,
        AVSampleRateKey: 44100,
        AVEncoderBitRateKey: 64000
    ]
    
    let activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 24)
    
    let activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 30)
    
    //MARK: ----- 设备\输入流 ----
    //获取摄像头
    private var currentVideoDevice: AVCaptureDevice!
    private var videoDevice: AVCaptureDevice? {
        if #available(iOS 13.0, *) {
            return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
        } else {
            return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: position).devices.first
        }
    }
    
    //获取麦克风
    private var audioDevice: AVCaptureDevice? {
        return AVCaptureDevice.default(for: .audio)
    }
    
    private(set) var videoWidth: CGFloat = 480
    private(set) var videoHeight: CGFloat = 640

    //MARK: ------ Session ---------
    private(set) lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.vga640x480
        return session
    }()
    
    override init() {
        super.init()
        
        if session.canSetSessionPreset(.hd1280x720) {
            videoWidth = 720
            videoHeight = 1280
            session.sessionPreset = AVCaptureSession.Preset.hd1280x720
        }
        if session.canSetSessionPreset(.hd1920x1080) {
            videoWidth = 1080
            videoHeight = 1920
            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
    }
}

extension CustomCaptureSession {
    func starCapture() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopCapture() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func changeTorchMode() {
        if position == .back,
           let current = currentVideoDevice {
            do {
                try current.lockForConfiguration()
                if current.torchMode == .on {
                    current.torchMode = .off
                } else {
                    current.torchMode = .on
                }
                current.unlockForConfiguration()
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func setInputs() {
        guard let video = videoDevice,
              let audio = audioDevice else {
            return
        }
        currentVideoDevice = video
        session.beginConfiguration()
        do {
            try video.lockForConfiguration()
            video.activeVideoMinFrameDuration = activeVideoMinFrameDuration
            video.activeVideoMaxFrameDuration = activeVideoMaxFrameDuration
            video.unlockForConfiguration()
            
            let videoInput = try AVCaptureDeviceInput(device: video)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            let audioInput = try AVCaptureDeviceInput(device: audio)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        } catch {
            debugPrint(error)
        }
        session.commitConfiguration()
    }
    
    private func removeInputs() {
        session.beginConfiguration()
        session.inputs.reversed().forEach{ session.removeInput($0) }
        session.commitConfiguration()
    }
}
