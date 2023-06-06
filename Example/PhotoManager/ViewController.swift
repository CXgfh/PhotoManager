//
//  ViewController.swift
//  PhotoManager
//
//  Created by oauth2 on 04/18/2023.
//  Copyright (c) 2023 oauth2. All rights reserved.
//

import UIKit
import PhotoManager
import Util_V
import SnapKit
import Photos

class ViewController: UIViewController {
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("开始", for: .normal)
        button.addTarget(self, action: #selector(star), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        
    }
}

extension ViewController {
    @objc private func star() {
        PhotoManager.sharde.delegate.add(self)
        //picker
//        PhotoManager.sharde.clickPattern = .edit
//        PhotoManager.sharde.openCustomImagePicker(parent: self,
//                                                  type: .video,
//                                                  ascending: false,
//                                                  assetSort: .creationDate,
//                                                  listPattern: .default)
        //camera
        PhotoManager.sharde.cameraType = .shooting
        PhotoManager.sharde.allowsEditing = true
        PhotoManager.sharde.openCustomCamera(parent: self)
    }
    
    //离开页面后 PhotoManager.sharde.delegate.remove(self)
}

extension ViewController: PhotoManagerDelegate {
    func photoManagerPickerResult(images: [UIImage]) {
        
    }
    
    func photoManagerPickerResult(assets: [PHAsset]) {
        
    }
    
    func photoManagerPickerResult(videos: [URL]) {
        
    }
    
    func photoManagerEditResult(image new: UIImage?) {
        
    }
    
    func photoManagerEditResult(video new: URL?) {
        
    }
    
    
}
