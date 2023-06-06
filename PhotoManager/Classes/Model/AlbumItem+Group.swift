//
//  AlbumItem+Group.swift
//  PhotoManager
//
//  Created by V on 2023/6/1.
//

import UIKit
import Photos
import Util_V

public protocol GroupAlbumItem: Any {
    var title: String? { get set }
    var items: [AlbumItem] { get }
}

public class TimeGroupAlbumItem: GroupAlbumItem {
    public var title: String?
    
    public var items: [AlbumItem] {
        return result
    }
    
    private var result: [AlbumItem]
    
    enum Group {
        case today
        case nearest
        case custom
        
        var date: Date {
            return Date().zeroTime
        }
        
        var gap: TimeInterval {
            switch self {
            case .today:
                return 24*60*60
            case .nearest:
                return 7*24*60*60
            case .custom:
                return 0
            }
        }
        
        var title: String {
            switch self {
            case .today:
                return "今天"
            case .nearest:
                return "近7天"
            default:
                return ""
            }
        }
    }
    
    private var groupList = [Group.today, .nearest, .custom]
    
    init(ablumItem: AlbumItem) {
        self.title = ablumItem.title
        self.result = []
        
        var current = groupList.removeFirst()
        var item = GroupAlbumSubItem(group: current)
        var i = 0
        while i < ablumItem.assets.count {
            if !item.belong(asset: ablumItem.assets[i]) {
                if !item.assets.isEmpty {
                    result.append(item)
                }
                if current == .custom {
                    item = GroupAlbumSubItem(group: current,
                                             asset: ablumItem.assets[i])
                    i += 1
                } else {
                    current = groupList.removeFirst()
                    item = GroupAlbumSubItem(group: current)
                }
            } else {
                i += 1
            }
        }
        result.append(item)
    }
    
    class GroupAlbumSubItem: AlbumItem {
        var title: String?
        
        var assets: [AlbumAsset] {
            return result
        }
        
        private var result: [AlbumAsset]
        
        private var date: Date
        
        private var group: Group
        
        init(group: Group) {
            self.group = group
            self.date = group.date
            
            self.title = group.title
            self.result = []
        }
        
        init(group: Group, asset: AlbumAsset) {
            self.group = group
            self.date = (asset.asset.creationDate ?? Date()).thisMonth
            
            self.title = self.date.makeString(by: "yyyy/MM")
            self.result = [asset]
        }
        
        func belong(asset: AlbumAsset) -> Bool {
            if group == .custom {
                if asset.asset.creationDate?.thisMonth == date {
                    result.append(asset)
                    return true
                } else {
                    return false
                }
            } else {
                let new = asset.asset.creationDate?.timeIntervalSince1970 ?? 0
                if new >= date.timeIntervalSince1970,
                   new - date.timeIntervalSince1970 < group.gap {
                    result.append(asset)
                    return true
                } else {
                    return false
                }
            }
        }
    }
}
