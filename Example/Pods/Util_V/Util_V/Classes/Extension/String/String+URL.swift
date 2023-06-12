//
//  String+CreatURL.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

/*
 FileManager.SearchPathDirectory
 documentDirectory 每次程序启动，都会生成一个私有目录
 libraryDirectory 库目录
 cachesDirectory 缓存目录
 
 FileManager.SearchPathDomainMask
 
 */

//MARK: -创建URL
public extension String {
    ///创建文件夹
    var createFolder: URL? {
        if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(self, isDirectory: true) {
            return url
        }
        return nil
    }
    
    ///创建AppGroup文件夹
    func createFolder(_ group: String) -> URL? {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appendingPathComponent(self, isDirectory: true) {
            return url
        }
        return nil
    }
    
    ///创建文件
    var createFile: URL? {
        if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(self) {
            return url
        }
        return nil
    }
    
    ///创建AppGroup文件
    func createFile(_ group: String) -> URL? {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)?.appendingPathComponent(self) {
            return url
        }
        return nil
    }
    
    ///创建临时文件夹
    var createTemporaryFolder: URL? {
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self)
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            return url
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    ///创建临时文件
    var createTemporaryFile: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(self)
    }
    
    var url: URL? {
        let path = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
        return URL(string: path)
    }
}


