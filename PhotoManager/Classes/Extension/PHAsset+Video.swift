//
//  PHAsset+Video.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/23.
//

import UIKit
import Photos

/*
 duration
 fileSize
 ppi
 bps
 */

public extension PHAsset {
    ///获取视频
    func getVideo(deliveryMode: PHVideoRequestOptionsDeliveryMode = .highQualityFormat,
                  progress: ((_ progress: Double) -> Void)? = nil,
                  completion:@escaping (_ asset: AVAsset?, _ info: [AnyHashable : Any]?)-> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = .current
        options.deliveryMode = deliveryMode
        options.progressHandler = { (current, error, stop, info) in
            progress?(current)
        }
        
        PHCachingImageManager.default().requestAVAsset(forVideo: self, options: options) { asset, _, info in
            DispatchQueue.main.async {
                completion(asset, info)
            }
        }
    }
    
    ///获取视频某一帧画面
    func getVideoImage(time: CMTime = CMTimeMakeWithSeconds(0.0,preferredTimescale: 600),
                       size: CGSize,
                       _ complete: @escaping (_ img: UIImage?) -> Void) {
        guard mediaType == .video else {
            return
        }
        getVideo(deliveryMode: .automatic) { asset, _ in
            guard let asset = asset else {
                return
            }
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                let genertor = AVAssetImageGenerator(asset: asset)
                genertor.appliesPreferredTrackTransform = true
                genertor.requestedTimeToleranceAfter = .zero
                genertor.requestedTimeToleranceBefore = .zero
                genertor.maximumSize = size
                var actualTime = CMTimeMake(value: 0, timescale: 0)
                let cgImage = try? genertor.copyCGImage(at: time, actualTime: &actualTime)
                if let cgImage = cgImage {
                    complete(UIImage(cgImage: cgImage))
                }
            }
        }
    }
    
    ///获取视频多帧画面
    func getVideoImages(count: Int,
                        _ complete: @escaping (_ imgs: [UIImage?]) -> Void) {
        let tem = self.duration/Double(count)
        var result = [CMTime]()
        for i in 0..<count {
            result.append(CMTimeMakeWithSeconds(Double(i)*tem, preferredTimescale: 600))
        }
        getVideoImages(times: result, complete)
    }
     
    ///获取视频多帧画面
    func getVideoImages(times: [CMTime],
                        _ complete: @escaping (_ imgs: [UIImage?]) -> Void) {
        guard mediaType == .video, times.count > 0 else {
            return
        }
        getVideo(deliveryMode: .automatic) { asset, _ in
            guard let asset = asset else {
                return
            }
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                let genertor = AVAssetImageGenerator(asset: asset)
                genertor.appliesPreferredTrackTransform = true
                genertor.requestedTimeToleranceAfter = .zero
                genertor.requestedTimeToleranceBefore = .zero
                var result = [UIImage?](repeating: nil, count: times.count)
                var count = 0
                for index in times.indices {
                    self.genertorImage(genertor, at: times[index]) { img in
                        result[index] = img
                        count += 1
                        if count == times.count {
                            DispatchQueue.main.async {
                                complete(result)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func genertorImage(_ genertor: AVAssetImageGenerator,
                               at time: CMTime,
                               _ complete: @escaping (_ img: UIImage?) -> Void) {
        var actualTime = CMTimeMake(value: 0, timescale: 0)
        let cgImage = try? genertor.copyCGImage(at: time, actualTime: &actualTime)
        if let cgImage = cgImage {
            complete(UIImage(cgImage: cgImage))
        }
    }
}
