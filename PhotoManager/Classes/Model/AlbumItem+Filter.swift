//
//  AlbumItem+Filter.swift
//  PhotoManager
//
//  Created by V on 2023/6/1.
//

import UIKit
import Photos

public class FilterAlbumItem: AlbumItem {
    
    public var title: String?
    
    public var assets: [AlbumAsset] {
        return result
    }
    
    private var result: [AlbumAsset]
    
    public init(albumItem: AlbumItem,
                type: PhotoManager.MediaType) {
        self.title = albumItem.title
        if let type = type.mediaType {
            self.result = albumItem.assets.filter{ $0.asset.mediaType == type }
        } else {
            self.result = albumItem.assets
        }
    }
    
    public func sort(ascending: Bool,
                     sort: PhotoManager.Sort) {
        switch sort {
        case .size:
            if ascending {
                result.sort{ $0.size < $1.size }
            } else {
                result.sort{ $0.size > $1.size }
            }
        case .creationDate:
            if ascending {
                result.sort{ ($0.asset.creationDate ?? Date()) < ($1.asset.creationDate ?? Date()) }
            } else {
                result.sort{ ($0.asset.creationDate ?? Date()) > ($1.asset.creationDate ?? Date()) }
            }
        case .modificationDate:
            if ascending {
                result.sort{ ($0.asset.modificationDate ?? Date()) < ($1.asset.modificationDate ?? Date()) }
            } else {
                result.sort{ ($0.asset.modificationDate ?? Date()) > ($1.asset.modificationDate ?? Date()) }
            }
        case .duration:
            if ascending {
                result.sort{ ($0.asset.modificationDate ?? Date()) < ($1.asset.modificationDate ?? Date()) }
            } else {
                result.sort{ ($0.asset.modificationDate ?? Date()) > ($1.asset.modificationDate ?? Date()) }
            }
        }
    }
}
