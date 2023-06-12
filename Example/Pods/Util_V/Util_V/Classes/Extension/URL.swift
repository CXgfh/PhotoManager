//
//  URL.swift
//  Util
//
//  Created by V on 2022/11/14.
//

import UIKit

//MARK: - message
public extension URL {
    /*
     FileAttributeKey 文件排序
     creationDate 创建日期
     modificationDate 最后修改日期
     */
    
    ///文件信息
    var messages: [FileAttributeKey: Any] {
        do {
            return try FileManager.default.attributesOfItem(atPath: self.path)
        } catch {
            debugPrint(error)
            return [:]
        }
    }
    
    ///子目录
    var childs: [URL] {
        do {
            return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [])
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    ///保存文件
    func saveFile(_ data: Data, message: String? = nil) {
        do {
            try data.write(to: self)
            debugPrint("保存文件成功", message as Any)
        } catch {
            debugPrint(error)
        }
    }
    
    ///删除文件
    func removeFile(message: String? = nil) {
        let fileManger = FileManager.default
        do {
            try fileManger.removeItem(at: self)
            debugPrint("移除文件成功", message as Any)
        } catch {
            debugPrint(error)
        }
    }
    
    ///移动文件
    func moveFile(to target: URL) {
        if FileManager.default.fileExists(atPath: self.absoluteString) {
            do {
                try FileManager.default.moveItem(at: self, to: target)
                debugPrint("移动文件成功")
            } catch {
                debugPrint("移动文件失败", error)
            }
        } else {
            debugPrint("源文件不存在")
        }
    }
    
    ///文件大小
    var size: UInt64 {
        return (self.messages[.size] as? NSNumber)?.uint64Value ?? 0
    }
}
