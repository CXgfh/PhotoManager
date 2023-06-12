//
//  MediaEditorManager+Format.swift
//  Vick_Custom
//
//  Created by Vick on 2022/8/3.
//

import UIKit
import AVKit

//MARK: -视频格式转换
extension MediaEditorManager {
    public func transformFormat(at asset: AVAsset,
                                to type: AVFileType,
                                _ complete: @escaping (_ result: MediaEditorResult)->()) {
        
        let url = self.temporaryFolder.appendingPathComponent(UUID().uuidString+type.suffix)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: exportPreset) else {
            complete(.failure(MediaEditorError.exportSession))
            return
        }
        self.currctExportSession = exportSession
        exportSession.outputURL = url
        exportSession.outputFileType = type
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
