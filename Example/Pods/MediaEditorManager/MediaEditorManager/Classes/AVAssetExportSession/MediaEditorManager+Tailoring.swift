//
//  MediaEditorManager+Tailoring.swift
//  Vick_Custom
//
//  Created by Vick on 2022/8/3.
//

import AVKit
import UIKit

//MARK: -视频裁剪
extension MediaEditorManager {
    public func tailoringVideo(at asset: AVAsset,
                               tailoring: MediaEditorTailoring,
                               _ complete: @escaping (_ result: MediaEditorResult)->()) {
        let start = CMTimeMakeWithSeconds(Double(tailoring.star)*asset.duration.seconds, preferredTimescale: asset.duration.timescale)
        let end = CMTimeMakeWithSeconds(Double(tailoring.end)*asset.duration.seconds, preferredTimescale: asset.duration.timescale)
        let range = CMTimeRange(start: start, end: end)
        
        tailoringVideo(at: asset, range, complete)
    }
    
    public func tailoringVideo(at asset: AVAsset,
                               _ range: CMTimeRange,
                               _ complete: @escaping (_ result: MediaEditorResult)->()) {
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: exportPreset) else {
            complete(.failure(MediaEditorError.exportSession))
            return
        }
        self.currctExportSession = exportSession
        exportSession.outputURL = url
        exportSession.outputFileType = self.type
        exportSession.timeRange = range
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case.completed:
                    complete(.success(url))
                case .cancelled:
                    complete(.failure(MediaEditorError.cancel))
                default:
                    if let error = exportSession.error {
                        complete(.failure(error))
                    } else {
                        complete(.failure(MediaEditorError.unowned))
                    }
                }
            }
        }
    }
}
