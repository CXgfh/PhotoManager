//
//  CustomCaptureWriter.swift
//  PhotoManager
//
//  Created by V on 2023/6/6.
//

import UIKit
import AVFoundation

protocol CustomCaptureWriterDelegate: AnyObject {
    func customCaptureWriterImage(image: UIImage)
    func customCaptureWriterVideo(url: URL)
}

class CustomCaptureWriter: NSObject {
    
    weak var delegate: CustomCaptureWriterDelegate?
    
    weak var session: CustomCaptureSession!
    
    var beganTakeImage = false
    
    var beganTakeVideo = false
    
    //MARK: ------ 输出流 --------
    //处理串行队列
    private let videoSemaphore = DispatchSemaphore(value: 1)
    private let videoQueue = DispatchQueue.global(qos: .userInteractive)
    
    private let audioSemaphore = DispatchSemaphore(value: 1)
    private let audioQueue = DispatchQueue.global(qos: .default)
    
    //视频输出流
    private lazy var videoOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [
            (kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value:kCVPixelFormatType_32BGRA)
        ] as [String : Any]
        output.alwaysDiscardsLateVideoFrames = false //在视频帧延迟到达时丢弃视频帧
        output.setSampleBufferDelegate(self, queue: videoQueue)
        return output
    }()
    
    //音频输出流
    private lazy var audioOutput: AVCaptureAudioDataOutput = {
        let output = AVCaptureAudioDataOutput()
        output.setSampleBufferDelegate(self, queue: audioQueue)
        return output
    }()
    
    //MARK: ----- writer --------
    private var url: URL!
    
    private var writer: AVAssetWriter!
    
    private var startTime: CMTime?
    
    private var videoWriterInput: AVAssetWriterInput!
    
    private var audioWriterInput: AVAssetWriterInput!
    
    
    init(session: CustomCaptureSession) {
        self.session = session
        super.init()
    }
}



extension CustomCaptureWriter {
    func setup() {
        session.session.beginConfiguration()
        if session.session.canAddOutput(videoOutput) {
            session.session.addOutput(videoOutput)
            if videoOutput.connection(with: .video)?.isVideoStabilizationSupported == true {
                videoOutput.connection(with: .video)?.videoOrientation = .landscapeLeft //将流经连接的视频旋转到给定方向
            }
        }
        
        if session.session.canAddOutput(audioOutput) {
            session.session.addOutput(audioOutput)
        }
        
        session.session.commitConfiguration()
    }
    
    private func getCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
    
    func startRecording() {
        startTime = nil
        url = (UUID().uuidString + ".mov").createFile!
        
        do {
            writer = try AVAssetWriter(url: url, fileType: .mov)
            videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: session.videoSetting)
            videoWriterInput.expectsMediaDataInRealTime = true
            if writer.canAdd(videoWriterInput) {
                writer.add(videoWriterInput)
            }
            
            audioWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: session.audioSetting)
            audioWriterInput.expectsMediaDataInRealTime = true
            if writer.canAdd(audioWriterInput) {
                writer.add(audioWriterInput)
            }
            
            self.writer.startWriting()
        } catch {
            debugPrint(error)
        }
    }

    func endRecording() {
        self.videoWriterInput.markAsFinished()
        self.audioWriterInput.markAsFinished()
        self.writer.finishWriting {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.delegate?.customCaptureWriterVideo(url: self.url)
            }
        }
    }
}

extension CustomCaptureWriter: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //MARK: ---- 拍照 -----
        captureImage(output, didOutput: sampleBuffer)
        
        //MARK: ----- 视频 -----
        if !session.session.isRunning {
            return
        }
        
        if let writer = self.writer,
            writer.status == .writing {
            
            if output == self.audioOutput {
                encodeAudioReadySampleBuffer(didOutput: sampleBuffer)
            } else {
                encodeVideoReadySampleBuffer(didOutput: sampleBuffer)
            }
        }
    }
    
    private func captureImage(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer) {
        if beganTakeImage, output == videoOutput {
            DispatchQueue.main.async {
                self.beganTakeImage = false
                self.session.stopCapture()
                if let pxielBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    let ciImage = CIImage(cvImageBuffer: pxielBuffer)
                    let image = UIImage(ciImage: ciImage)
                    self.delegate?.customCaptureWriterImage(image: image)
                } else {
                    debugPrint("拍照失败")
                }
            }
        }
    }
    
    private func encodeVideoReadySampleBuffer(didOutput sampleBuffer: CMSampleBuffer) {
        guard let input = videoWriterInput else {
            return
        }
        
        if videoSemaphore.wait(timeout: .now()) != .success {
            debugPrint("视频丢帧")
            return
        }
        
        if startTime == nil {
            videoQueue.sync {
                let time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
                self.writer.startSession(atSourceTime: time)
                self.startTime = time
            }
        }
        
        //等待input空闲
        while !input.isReadyForMoreMediaData {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }
        
        if input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        } else {
            debugPrint("视频丢帧")
        }
        
        videoSemaphore.signal()
    }
    
    private func encodeAudioReadySampleBuffer(didOutput sampleBuffer: CMSampleBuffer) {
        
        guard let input = audioWriterInput else {
            return
        }
        
        if audioSemaphore.wait(timeout: .now()) != .success {
            debugPrint("音频丢帧")
            return
        }
        
        if startTime == nil {
            audioQueue.sync {
                let time = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
                self.writer.startSession(atSourceTime: time)
                self.startTime = time
            }
        }
        
        //等待input空闲
        while !input.isReadyForMoreMediaData {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }
        
        if input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        } else {
            debugPrint("音频丢帧")
        }
        
        audioSemaphore.signal()
    }
}
