//
//  PHAsset+Image.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/23.
//

import UIKit
import Photos

public extension PHAsset {
    ///获取图片
    func getImage(by size: CGSize = PHImageManagerMaximumSize,
                  deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
                  progress: ((_ progress: Double) -> Void)? = nil,
                  completion: @escaping (_ image: UIImage?, _ info: [AnyHashable : Any]?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        options.resizeMode = .none
        options.deliveryMode = deliveryMode
        options.isSynchronous = true
        options.progressHandler = { (current, error, stop, info) in
            progress?(current)
        }
        PHCachingImageManager.default().requestImage(for: self, targetSize: size, contentMode: .default, options: options) { (image, info) in
            DispatchQueue.main.async {
                completion(image, info)
            }
        }
        
    }
}
