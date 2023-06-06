//
//  PhotoManager+Storage.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/20.
//

import UIKit
import Photos



//MARK: -存储
extension PhotoManager {
    ///保存视频
    public func saveVideo(at url: URL) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.relativePath) {
            UISaveVideoAtPathToSavedPhotosAlbum(url.relativePath, self, #selector(saveVideoStatus), nil)
        } else {
            delegate.call {
                $0.photoManagerSaveCompletion?(false, error: NSError(domain: "photo.open.error", code: 0, userInfo: [NSLocalizedDescriptionKey : "设备不支持该视频格式"]))
            }
        }
    }

    @objc private func saveVideoStatus(_ urlstr: String, _ error: NSError?, _ contextInfo: UnsafeRawPointer){
        delegate.call {
            let flag = error == nil
            $0.photoManagerSaveCompletion?(flag, error: error)
        }
    }

    ///保存图片
    public func saveImage(at image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageStatus), nil)
    }

    @objc private func saveImageStatus(_ image: UIImage, _ error: NSError?, _ contextInfo: UnsafeRawPointer) {
        delegate.call {
            let flag = error == nil
            $0.photoManagerSaveCompletion?(flag, error: error)
        }
    }
    
    //MARK: -删除
    public func deleteAssets(ids: Set<String>, completionHandler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: Array(ids), options: nil)
            PHAssetChangeRequest.deleteAssets(assets)
        }, completionHandler: completionHandler)
    }
    
    public func deleteAssets(assets: [PHAsset], completionHandler: ((Bool, Error?) -> Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }, completionHandler: completionHandler)
    }
}
