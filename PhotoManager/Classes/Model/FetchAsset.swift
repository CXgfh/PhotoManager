//
//  PhotoManager+FetchAsset.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/26.
//

import UIKit
import Photos

/*
 albumRegular 在照片应用程序中创建的相册
 albumSyncedEvent 从iPhoto同步到设备的事件
 albumSyncedFaces 一个从iPhoto同步到设备的Faces组
 albumSyncedAlbum 从iPhoto同步到设备的相册
 albumImported 从相机或外部存储器导入的相册
 
 albumMyPhotoStream 用户的个人iCloud照片流
 albumCloudShared 一个iCloud共享照片流
 
 smartAlbumGeneric 其他
 smartAlbumPanoramas 全景
 smartAlbumVideos 视频
 smartAlbumFavorites 收藏夹
 smartAlbumTimelapses 延时视频
 smartAlbumAllHidden 隐藏资产
 smartAlbumRecentlyAdded 最近添加
 smartAlbumBursts 分组所有突发的照片序列
 smartAlbumSlomoVideos 慢动作
 smartAlbumUserLibrary 起源于用户自己的库(相对于资产从iCloud共享相册)
 smartAlbumSelfPortraits 自拍
 smartAlbumScreenshots 截图
 smartAlbumDepthEffect 景深
 smartAlbumLivePhotos 所有的Live Photo资产
 smartAlbumAnimated gif
 smartAlbumLongExposures 所有的Live Photo资产，其中长曝光变化是启用的
 smartAlbumUnableToUpload 系统无法上传到iCloud的所有资产
 */

extension PhotoManager {
    //获取系统主相册
    private func fetchAsset() -> PHFetchResult<PHAsset> {
        return PHAsset.fetchAssets(with: nil)
    }
    
    //获取系统子相册
    private func fetchAsset(by subtype: PHAssetCollectionSubtype) -> (title: String?, fetchResult: PHFetchResult<PHAsset>)? {
        if let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil).firstObject {
            return (title: collection.localizedTitle, fetchResult: PHAsset.fetchAssets(in: collection, options: nil))
        }
        return nil
    }
    
    //获取用户相册
    private func fetchUserAsset() -> [(title: String?, fetchResult: PHFetchResult<PHAsset>)] {
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        var result = [(String?, PHFetchResult<PHAsset>)]()
        for index in 0..<userCollections.count {
            if let collection = userCollections.object(at: index) as? PHAssetCollection {
                result.append((collection.localizedTitle, PHAsset.fetchAssets(in: collection, options: nil)))
            }
        }
        return result
    }
}

extension PhotoManager {
    ///获取所有相册
    public func fetchAllAlbums() {
        var items = [AlbumItem]()
        fetchResult = fetchAsset()
        items.append(MessageAlbumItem(title: "系统相册", fetchResult: fetchResult))
        let userAsset = fetchUserAsset()
        for index in userAsset {
            items.append(MessageAlbumItem(title: index.title, fetchResult: index.fetchResult))
        }
        
        var types: [PHAssetCollectionSubtype] = [
            .smartAlbumVideos,
            .smartAlbumFavorites,
            .smartAlbumRecentlyAdded,
            .smartAlbumSelfPortraits,
            .smartAlbumScreenshots,
        ]
        
        if #available(iOS 10.2, *) {
            types.append(.smartAlbumDepthEffect)
        }
        
        let subAlbums = fetchSpecifiedAlbums(subtype: types)
        items += subAlbums
        
        items = items.filter({ !$0.assets.isEmpty })
        
        albums = items
    }
    
    ///获取指定子相册
    private  func fetchSpecifiedAlbums(subtype: [PHAssetCollectionSubtype]) -> [AlbumItem] {
        var items = [AlbumItem]()
        for index in subtype {
            if let subAsset = fetchAsset(by: index) {
                items.append(MessageAlbumItem(title: subAsset.title, fetchResult: subAsset.fetchResult))
            }
        }
        
        items = items.filter({ !$0.assets.isEmpty })
        return items
    }
    
    public func delAssetAtAlbums(_ assets: [PHAsset]) {
        deleteAssets(assets: assets) { result, error in
            self.delegate.call{
                $0.photoManagerDelCompletion?(result, error: error)
            }
        }
    }
}

