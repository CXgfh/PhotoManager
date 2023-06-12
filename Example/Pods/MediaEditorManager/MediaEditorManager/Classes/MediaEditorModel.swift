//
//  MediaEditorModel.swift
//  MediaEditorManager
//
//  Created by V on 2023/5/22.
//

import UIKit
import AVFoundation

extension AVFileType {
    var suffix: String {
        switch self {
        case .mp4:
            return ".mp4"
        default:
            return ".mov"
        }
    }
}

public enum MediaEditorAngle: Int {
    case degrees0 = 0
    case degrees180 = 180
    case degrees90 = 90
    case degrees270 = 270
    case degreesNegative180 = -180
}

public struct RotationMessage {
    public var transform: CGAffineTransform
    public var size: CGSize
    
    public init(transform: CGAffineTransform, size: CGSize) {
        self.transform = transform
        self.size = size
    }
}

public struct MediaEditorTailoring {
    var star: Float
    var end: Float
    
    public init(star: Float, end: Float) {
        self.star = star
        self.end = end
    }
}

public struct MediaEditorCompression {
    var audioMix: AVAudioMix?
    var videoSettings: [String: Any]
    var audioSettings: [String: Any]?
    
    public init(audioMix: AVAudioMix? = nil, videoSettings: [String : Any], audioSettings: [String : Any]? = nil) {
        self.audioMix = audioMix
        self.videoSettings = videoSettings
        self.audioSettings = audioSettings
    }
}

public struct MediaEditorWaterMaker {
    var image: UIImage?
    var centerOffsetX: CGFloat
    var centerOffsetY: CGFloat
    var animations: [CAKeyframeAnimation]
    var star: CMTime
    var duration: Double
    
    public init(image: UIImage?, centerOffsetX: CGFloat, centerOffsetY: CGFloat, star: CMTime, duration: Double) {
        self.image = image
        self.centerOffsetX = centerOffsetX
        self.centerOffsetY = centerOffsetY
        self.star = star
        self.duration = duration
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [1, 1]
        animation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 1.0)]
        animation.beginTime = CMTimeGetSeconds(star)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        self.animations = [animation]
    }
    
    public mutating func addAnimation(keyPath: String,
                                      values: [Any],
                                      keyTimes: [NSNumber]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.values = values
        animation.keyTimes = keyTimes
        animation.beginTime = CMTimeGetSeconds(star)
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        self.animations.append(animation)
    }
}
