//
//  MediaEditorManager+Combining.swift
//  Vick_Custom
//
//  Created by Vick on 2022/8/3.
//

import UIKit
import AVKit

//MARK: -视频拼接
extension MediaEditorManager {
    ///多视频拼接
    public func combinedGrowthVideo(by assets: [AVAsset],
                                    _ complete: @escaping (_ result: MediaEditorResult)->()) {
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID()) else {
            complete(.failure(MediaEditorError.creatEmptyTrack))
            return
        }
        
        var flag = 0
        for index in assets.reversed() { //从头部插入，免TimeRange计算
            if let track = index.tracks(withMediaType: .video).first {
                let time = CMTimeRangeMake(start: .zero, duration: index.duration)
                do {
                    try compositionTrack.insertTimeRange(time, of: track, at: .zero)
                } catch {
                    flag = 1
                }
            } else {
                flag = 2
            }
        }
        
        if flag == 1 {
            complete(.failure(MediaEditorError.insetTrack))
            return
        } else if flag == 2 {
            complete(.failure(MediaEditorError.getVideoTrack))
            return
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: exportPreset) else {
            complete(.failure(MediaEditorError.exportSession))
            return
        }
        self.currctExportSession = exportSession
        exportSession.outputURL = url
        exportSession.outputFileType = self.type
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
