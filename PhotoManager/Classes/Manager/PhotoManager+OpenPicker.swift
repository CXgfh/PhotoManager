//
//  PhotoManager+OpenPicker.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/27.
//

import UIKit
import Photos
import Util_V

//MARK: ---- 自定义图库 -----
public extension PhotoManager {
    private struct AssociatedKeys {
        static var click = "click"
        static var ascending = "sortIsAscending"
        static var sort = "assetSort"
        static var mediaType = "AlbumAssetMediaType"
    }
    
    enum ClickPattern {
        case picker(_ max: Int)
        case detail
        case edit
        case waterMaker
    }
    
    enum Sort: CaseIterable, NormalPopoverOption {
        var title: String {
            switch self {
            case .size:
                return "文件大小"
            case .creationDate:
                return "创建时间"
            case .modificationDate:
                return "修改时间"
            case .duration:
                return "时长"
            }
        }
        
        case size
        case creationDate
        case modificationDate
        case duration
    }

    enum MediaType: CaseIterable, NormalPopoverOption {
        case all
        case image
        case video
        case audio
        
        var mediaType: PHAssetMediaType? {
            switch self {
            case .all:
                return nil
            case .image:
                return .image
            case .video:
                return .video
            case .audio:
                return .audio
            }
        }
        
        var title: String {
            switch self {
            case .image:
                return "图片"
            case .video:
                return "视频"
            case .audio:
                return "音频"
            default:
                return "所有"
            }
        }
    }
    
    var clickPattern: ClickPattern {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.click) as? ClickPattern ?? .detail
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.click, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var ascending: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ascending) as? Bool ?? false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.ascending, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var sort: Sort {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.sort) as? Sort ?? .creationDate
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.sort, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    internal var type: MediaType {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.mediaType) as? MediaType ?? .all
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.mediaType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func openCustomImagePicker(parent: UIViewController,
                               type: MediaType = .all,
                               ascending: Bool = false,
                               assetSort: Sort = .creationDate,
                               listPattern: ListPattern = .default) {
        checkPhotoAuthorization(parent: parent, message: photoMessage) { [weak self] in
            guard let self = self else { return }
            if self.type != type
                || self.ascending != ascending
                || self.sort != assetSort
                || self.listPattern != listPattern {
                if isLoading {
                    self.needUpdate = (type, ascending, assetSort, listPattern)
                } else {
                    self.type = type
                    self.ascending = ascending
                    self.sort = assetSort
                    self.listPattern = listPattern
                    self.isLoading = true
                    self.update()
                }
            }
            let vc = CustomImagerPickerViewController(pattern: listPattern)
            let nac = BaseNavigationController(rootViewController: vc, backImage: UIImage(photo: "picker_return"))
            parent.swipePresent(vc: nac, animated: true)
        }
    }
}

