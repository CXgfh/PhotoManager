//
//  MediaEditorManager+WaterMaker.swift
//  Vick_Custom
//
//  Created by Vick on 2022/8/3.
//

import UIKit
import AVKit

//MARK: -视频水印
extension MediaEditorManager {
    ///自定义水印动画
    public func waterMaker(at asset: AVAsset,
                           waterMakers: [MediaEditorWaterMaker],
                           _ complete: @escaping (_ result: MediaEditorResult)->()) {
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            complete(.failure(MediaEditorError.getVideoTrack))
            return
        }
        
        let composition = AVMutableComposition()
        
        guard let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID()) else {
            complete(.failure(MediaEditorError.creatEmptyTrack))
            return
        }
        
        do {
            try compositionTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: asset.duration), of: track, at: .zero)
        } catch {
            complete(.failure(MediaEditorError.insetTrack))
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: exportPreset) else {
            complete(.failure(MediaEditorError.exportSession))
            return
        }
        self.currctExportSession = exportSession
        exportSession.videoComposition = videoComposition(tracks: [compositionTrack], angle: .degrees0, waterMakers: waterMakers, time: CMTimeRangeMake(start: .zero, duration: asset.duration))
        exportSession.outputFileType = self.type
        exportSession.outputURL = url
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
