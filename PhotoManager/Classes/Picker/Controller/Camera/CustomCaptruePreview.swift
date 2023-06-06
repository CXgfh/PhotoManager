//
//  CustomCaptruePreview.swift
//  PhotoManager
//
//  Created by V on 2023/6/6.
//

import UIKit
import AVFoundation

class CustomCaptruePreview: NSObject {

    // 预览图层
    private(set) var previewLayer: AVCaptureVideoPreviewLayer
    
    init(session: AVCaptureSession) {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        super.init()
    }
}
