//
//  MediaDataEditorManager.swift
//  MediaEditorManager
//
//  Created by V on 2023/2/26.
//

import UIKit
import AVFoundation

public class MediaDataEditorManager {

    internal var type: AVFileType = .mov
    
    internal var temporaryFolder: URL!
    
    internal var writeVideoCompleted = true
    
    internal var writeAudioCompleted = true
    
    internal lazy var timeRange = CMTimeRangeMake(start: .zero, duration: .indefinite)
    
    internal lazy var inputQueue = DispatchQueue(label: "com.mediaDataEditor.serialQueue")
    
    //直接拿到原始数据进行解码操作，不改变数据
    internal var reader: AVAssetReader!
    internal var videoOutput: AVAssetReaderVideoCompositionOutput!
    internal var audioOutput: AVAssetReaderAudioMixOutput!
    
    internal var writer: AVAssetWriter!
    internal var videoInput: AVAssetWriterInput!
    internal var audioInput: AVAssetWriterInput!
    
    internal var videoPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    //MARK: -----
    public var shouldOptimizeForNetworkUse = false
    
    public var expectsMediaDataInRealTime = false
    
    public var alwaysCopiesSampleData = false
    
    public init() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("MediaDataEditor" + UUID().uuidString)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            self.temporaryFolder = url
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

extension MediaDataEditorManager {
    ///支持mp4，mov
    public func changedAVType(type: AVFileType) {
        switch type {
        case .mp4:
            self.type = .mp4
        default:
            self.type = .mov
        }
    }
    
    public func cancelReaderAndWriter() {
        inputQueue.async {
            self.writeAudioCompleted = true
            self.writeVideoCompleted = true
            self.writer.cancelWriting()
            self.reader.cancelReading()
        }
    }
}
