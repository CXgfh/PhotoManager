//
//  PhotoManager+OpenCamera.swift
//  PhotoManager
//
//  Created by V on 2023/5/9.
//

import UIKit
import Util_V

public extension PhotoManager {
    
    private struct AssociatedKeys {
        static var editing = "allowsEditing"
        static var type = "cameraType"
        
    }
    
    enum CameraType {
        case shooting
        case continuousShooting
        case video
    }
    
    var allowsEditing: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.editing) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.editing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var cameraType: CameraType {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.type) as? CameraType ?? .shooting
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.type, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func openCustomCamera(parent: UIViewController) {
        checkAVCaptureAuthorization(parent: parent, for: .video, message: cameraMessage) {
            checkAVCaptureAuthorization(parent: parent, for: .audio, message: self.audioMessage) {
                let vc = CustomCameraViewController()
                parent.swipePresent(vc: vc, animated: true)
            }
        }
    }
}
