//
//  PhotoManager+SystemPicker.swift
//  PhotoManager
//
//  Created by V on 2023/5/31.
//

import UIKit
import Util_V

//MARK: --- 系统图库 ----
extension PhotoManager: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func openSystemPicker(parent: UIViewController,
                                 allowsEditing: Bool) {
        checkPhotoAuthorization(parent: parent,
                                message: photoMessage) {
            self.openImagePickerController(parent: parent, allowsEditing: allowsEditing, type: .photoLibrary)
        }
    }
    
    func openSystemCamera(parent: UIViewController, allowsEditing: Bool) {
        checkAVCaptureAuthorization(parent: parent,
                                    for: .video,
                                    message: cameraMessage) {
            checkAVCaptureAuthorization(parent: parent, for: .audio, message: self.audioMessage) {
                self.openImagePickerController(parent: parent, allowsEditing: true, type: .camera)
            }
        }
    }
    
    func openImagePickerController(parent: UIViewController,
                                   allowsEditing: Bool,
                                   type: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) {
            let picker = UIImagePickerController()
            picker.allowsEditing = allowsEditing
            picker.sourceType = type
            if type == .camera {
                picker.showsCameraControls = true
            }
            picker.delegate = self
            picker.modalTransitionStyle = .crossDissolve
            picker.modalPresentationStyle = .fullScreen
            parent.present(picker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[self.allowsEditing ? .editedImage : .originalImage] as? UIImage {
                self.delegate.call{
                    $0.photoManagerPickerResult?(images: [image])
                }
            }
            if let video = info[.mediaURL] as? URL {
                self.delegate.call{
                    $0.photoManagerPickerResult?(videos: [video])
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
