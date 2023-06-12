//
//  Authorization.swift
//  CustomManager
//
//  Created by Vick on 2022/9/13.
//

import UIKit
import Photos

public func checkAVCaptureAuthorization(parent: UIViewController,
                                        for mediaType: AVMediaType,
                                        title: String? = nil,
                                        message: String? = nil,
                                        cancel: String = "取消",
                                        confirm: String = "去设置",
                                        _ authorizedBlock: @escaping () -> Void) {
    let status = AVCaptureDevice.authorizationStatus(for: mediaType)
    switch status {
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: mediaType) { granted in
            DispatchQueue.main.async {
                if granted {
                    authorizedBlock()
                }
            }
        }
    case .denied, .restricted:
        openSettings(parent: parent, title: title, message: message, cancel: cancel, confirm: confirm)
    case .authorized:
        authorizedBlock()
    @unknown default:
        break
    }
}

public func checkPhotoAuthorization(parent: UIViewController,
                                    title: String? = nil,
                                    message: String? = nil,
                                    cancel: String = "取消",
                                    confirm: String = "去设置",
                                    _ authorizedBlock: @escaping () -> Void) {
    let currentStatus = PHPhotoLibrary.authorizationStatus()
    switch currentStatus {
    case .notDetermined:
        PHPhotoLibrary.requestAuthorization { status in
            if #available(iOS 14, *) {
                if status == .authorized || status == .limited {
                    DispatchQueue.main.async {
                        authorizedBlock()
                    }
                }
            } else {
                if status == .authorized {
                    DispatchQueue.main.async {
                        authorizedBlock()
                    }
                }
            }
        }
    case .authorized, .limited:
        authorizedBlock()
    case .denied:
        openSettings(parent: parent, title: title, message: message, cancel: cancel, confirm: confirm)
    default:
        break
    }
}


