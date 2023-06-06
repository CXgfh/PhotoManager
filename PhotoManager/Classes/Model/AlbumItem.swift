//
//  PhotoManager+Model.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/26.
//

import UIKit
import Photos

public protocol AlbumItem: Any {
    var title: String? { get set }
    var assets: [AlbumAsset] { get }
}

public protocol AlbumAsset: Any {
    var asset: PHAsset { get set }
    var size: Int64 { get set }
}

public class MessageAlbumItem: AlbumItem {
    
    public var title: String?
    
    public var assets: [AlbumAsset] {
        return result
    }
    
    private var result: [MessagePHAsset]
    
    init(title: String?, fetchResult: PHFetchResult<PHAsset>, isDefault: Bool = false) {
        self.title = title
        var tem = [MessagePHAsset]()
        for index in 0..<fetchResult.count {
            tem.append(MessagePHAsset(fetchResult[index]))
        }
        self.result = tem
    }
}

public struct MessagePHAsset: AlbumAsset, Hashable {
    public var asset: PHAsset
    public var size: Int64 = 0
    var hashMessage: NSString?
    
    init(_ asset: PHAsset) {
        self.asset = asset
        if let resource = PHAssetResource.assetResources(for: asset).first,
           let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
            self.size = Int64(bitPattern: UInt64(unsignedInt64))
        }
    }
    
    mutating func addHashMessage(_ message: NSString) {
        self.hashMessage = message
    }
}

///哈希集

//public struct HashAlbumItem {
//    var title: String?
//    var hashResult: [HashPHAsset]
//    var isDefault: Bool
//
//    init(title: String?, isDefault: Bool = false) {
//        self.title = title
//        self.hashResult = []
//        self.isDefault = isDefault
//    }
//
//    mutating func addHashResult(_ result: HashPHAsset) {
//        self.hashResult.append(result)
//    }
//}
//
//public struct SaimilarityAlbumItem {
//    var title: String?
//    var saimilarityResult: [[HashPHAsset]]
//    var isDefault: Bool
//
//    init(_ item: HashAlbumItem) {
//        self.title = item.title
//        self.isDefault = item.isDefault
//        if item.hashResult.isEmpty {
//            self.saimilarityResult = []
//        } else {
//            var reslut = [[HashPHAsset]]()
//            for i in 0..<item.hashResult.count {
//                var flag = true
//                for j in 0..<reslut.count {
//                    if reslut[j].first == item.hashResult[i] {
//                        reslut[j].append(item.hashResult[i])
//                        flag = false
//                        break
//                    }
//                }
//                if flag {
//                    reslut.append([item.hashResult[i]])
//                }
//            }
//            self.saimilarityResult = reslut
//        }
//    }
//}
//
//public struct HashPHAsset: Equatable {
//    var asset: PHAsset
//    var fastImage: UIImage?
//    var hashString: NSString
//
//    init(_ asset: PHAsset, fastImage: UIImage?) {
//        self.asset = asset
//        self.fastImage = fastImage
//        self.hashString = fastImage?.grayImage?.pHashValueWithImage ?? ""
//    }
//

//}
