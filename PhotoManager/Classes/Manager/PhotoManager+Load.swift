//
//  VPhotoManage.swift
//
//
//  Created by Frank on 2021/6/15.
//

import UIKit
import Photos
import Util_V

@objc public protocol PhotoManagerDelegate: AnyObject {
    @objc optional func photoManagerDidLoad()
    
    @objc optional func photoManagerDelCompletion(_ result: Bool, error: Error?)
    @objc optional func photoManagerSaveCompletion(_ result: Bool, error: NSError?)
    @objc optional func photoManagerPickerResult(assets: [PHAsset])
    @objc optional func photoManagerPickerResult(images: [UIImage])
    @objc optional func photoManagerPickerResult(videos: [URL])
    
    @objc optional func photoManagerLockTheScreen()
    @objc optional func photoManagerUnlockTheScreen()
    @objc optional func photoManagerSpecifiedScreen(_ mask: UIInterfaceOrientationMask)
    
    @objc optional func photoManagerEditResult(image new: UIImage?)
    @objc optional func photoManagerEditResult(video new: URL?)
    //
    @objc optional func photoManagerCrameResult(image: UIImage?)
    @objc optional func photoManagerCrameResult(video: URL, width: CGFloat, height: CGFloat)
}

public class PhotoManager: NSObject {
    
    public enum ListPattern {
        case `default`
        case time
        case similarity
    }
    
    public static let sharde = PhotoManager()
    
    public var delegate = DelegateCenter<PhotoManagerDelegate>()
    
    public var cameraMessage: String = "相机权限未开启，请允许\(Util.appName)访问您的相机"
    
    public var audioMessage: String = "麦克风权限未开启，请允许\(Util.appName)访问您的麦克风"
    
    public var photoMessage: String = "相册权限未开启，请允许\(Util.appName)访问您的相册"
    
    internal var isLoading = true
    
    internal var needUpdate: (MediaType, Bool, Sort, ListPattern)?
    
    private var queue = DispatchQueue(label: "photoCatchQueue")
    
    internal var fetchResult = PHFetchResult<PHAsset>()
    
    internal var albums = [AlbumItem]()
    
    internal var listPattern: ListPattern = .default
    
    public internal(set) var defualtAlbums = [AlbumItem]()
    
    public internal(set) var groupingAlbums: GroupAlbumItem!
    
    public override init() {
        super.init()
        PHPhotoLibrary.shared().register(self)
    }
}

public extension PhotoManager {
    func setup() {
        debugPrint("photoStartLoad")
        queue.async {
            self.fetchAllAlbums()
        }
        self.update()
    }
    
    func update() {
        queue.async {
            switch self.listPattern {
            case .similarity:
                break
            case .time:
                self.groupingTime()
            case .default:
                self.filterAlbums()
                self.sortAlbums()
            }
            if let needUpdate = self.needUpdate {
                self.type = needUpdate.0
                self.ascending = needUpdate.1
                self.sort = needUpdate.2
                self.listPattern = needUpdate.3
                self.needUpdate = nil
                self.update()
                debugPrint("photoNeedUpdate")
            } else {
                self.isLoading = false
                DispatchQueue.main.async {
                    debugPrint("photoDidLoad")
                    self.delegate.call{ $0.photoManagerDidLoad?() }
                }
            }
        }
    }
    
    func filterAlbums() {
        self.defualtAlbums = []
        for album in self.albums {
            self.defualtAlbums.append(FilterAlbumItem(albumItem: album, type: self.type))
        }
    }
    
    func sortAlbums() {
        for index in self.defualtAlbums.indices {
            (self.defualtAlbums[index] as? FilterAlbumItem)?.sort(ascending: self.ascending, sort: self.sort)
        }
    }
    
    func groupingTime() {
        if let album = self.albums.first {
            var new = FilterAlbumItem(albumItem: album, type: self.type)
            new.sort(ascending: false, sort: .creationDate)
            self.groupingAlbums = TimeGroupAlbumItem(ablumItem: new)
        }
    }
    
    func clearn() {
        isLoading = true
        albums = []
        defualtAlbums = []
        groupingAlbums = nil
    }
}

extension PhotoManager: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        let changes = changeInstance.changeDetails(for: fetchResult)
        changes?.fetchResultAfterChanges
        //V_V 会触发2次
        isLoading = true
        setup()
    }
}

extension UIImage {
    convenience init?(photo named: String) {
        if let url = Bundle(for: PhotoManager.self).url(forResource: "PhotoManager", withExtension: "bundle") {
            self.init(named: named, in: Bundle(url: url), compatibleWith: nil)
        } else {
            self.init(named: named, in: Bundle(for: PhotoManager.self), compatibleWith: nil)
        }
    }
}

extension UIColor {
    convenience init?(photo named: String) {
        if let url = Bundle(for: PhotoManager.self).url(forResource: "PhotoManager", withExtension: "bundle") {
            self.init(named: named, in: Bundle(url: url), compatibleWith: nil)
        } else {
            self.init(named: named, in: Bundle(for: PhotoManager.self), compatibleWith: nil)
        }
    }
}
