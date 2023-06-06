

import Photos
import UIKit

public extension PHAsset {
    ///是否在云盘
    func isICloud(completion: @escaping (_ result: Bool) -> Void) {
        switch self.mediaType {
        case .video:
            let options = PHVideoRequestOptions()
            options.version = .current
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = false
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (asset, mix, info) in
                DispatchQueue.main.async {
                    completion(asset == nil)
                }
            }
        case .image:
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.version = .current
            options.resizeMode = .none
            options.isNetworkAccessAllowed = false
            options.isSynchronous = true
            PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { (image, info) in
                DispatchQueue.main.async {
                    completion(image == nil)
                }
            }
        default:
            break
        }
    }
    
    ///获取url
    func getURL(completionHandler : @escaping ((_ url: URL?) -> Void)){
        switch mediaType {
        case .image:
            let options = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = { _ in return false }
            self.requestContentEditingInput(with: options) { input, info in
                DispatchQueue.main.async {
                    if let url = input?.fullSizeImageURL {
                        completionHandler(url)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        case .video:
            let options = PHVideoRequestOptions()
            options.version = .current
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { asset, audioMix, info in
                DispatchQueue.main.async {
                    if let url = (asset as? AVURLAsset)?.url {
                        completionHandler(url)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
        default:
            break
        }
    }
}
