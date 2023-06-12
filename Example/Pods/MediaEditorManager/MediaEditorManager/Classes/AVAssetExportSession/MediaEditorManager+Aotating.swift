//
//  MediaEditorManager+Correction.swift
//  Vick_Custom
//
//  Created by Vick on 2022/7/27.
//

import UIKit
import AVKit



//MARK: - 视频旋转
extension MediaEditorManager {
    ///视频校正
    public func correctingVideo(at asset: AVAsset,
                                by angle: MediaEditorAngle = .degrees0,
                                _ complete: @escaping (_ result: MediaEditorResult)->()) {
        guard let track = asset.tracks(withMediaType: .video).first else {
            complete(.failure(MediaEditorError.getVideoTrack))
            return
        }
        
        let current = videoAngle(track)
        guard angle.rawValue != current else {
            let url = (asset as? AVURLAsset)?.url
            complete(.success(url))
            return
        }
        
        let time = CMTimeRangeMake(start: .zero, duration: asset.duration)
        let message = videoCorrectingMessage(track, angle: angle.rawValue)
        
        aotatingVideo(track, time, message, complete)
    }
    
    ///视频旋转
    internal func aotatingVideo(_ track: AVAssetTrack,
                                _ time: CMTimeRange,
                                _ message: RotationMessage,
                                _ complete: @escaping (_ result: MediaEditorResult)->()) {
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        
        let composition = AVMutableComposition()
        guard let compositionvideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID()) else {
            complete(.failure(MediaEditorError.creatEmptyTrack))
            return
        }
        
        do {
            try compositionvideoTrack.insertTimeRange(time, of: track, at: .zero)
        } catch {
            complete(.failure(MediaEditorError.insetTrack))
            return
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: exportPreset) else {
            complete(.failure(MediaEditorError.exportSession))
            return
        }
        
        self.currctExportSession = exportSession
        exportSession.videoComposition = aotatingVideoComposition(compositionvideoTrack, message, time)
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
    
    ///视频旋转指令(合成视频帧的说明)
    internal func aotatingVideoComposition(_ track: AVAssetTrack,
                                           _ message: RotationMessage,
                                           _ time: CMTimeRange) -> AVVideoComposition {
        //媒体图层指令对象
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        layerinstruction.setTransform(message.transform, at: .zero)
        
        //媒体指令对象
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = time
        instruction.layerInstructions = [layerinstruction]
        
        //媒体合成对象
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = track.minFrameDuration
        layerComposition.renderSize = message.size
        layerComposition.instructions = [instruction]
        return layerComposition
    }
}
