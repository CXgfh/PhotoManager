//
//  MD5.swift
//  Pods-Util_V_Example
//
//  Created by V on 2023/5/31.
//

import Foundation
import CommonCrypto

public extension URL {
    var md5: String? {
        do {
            let file = try FileHandle.init(forReadingFrom: self)
            defer {
                file.closeFile()
            }
            var context = CC_MD5_CTX()
            CC_MD5_Init(&context)
            while case let data = file.readData(ofLength: 1024*1024), data.count > 0 {
                data.withUnsafeBytes { poiner in
                    _ = CC_MD5_Update(&context, poiner, CC_LONG(data.count))
                }
            }

            // 计算MD5摘要
            var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            digest.withUnsafeMutableBytes { (pointer) -> Void in
                _ = CC_MD5_Final(pointer, &context)
            }
            let result = digest.map { (byte) -> String in
                String(format: "%02hhx", byte)
            }.joined()
            return result
        } catch {
            debugPrint(error)
            return nil
        }
    }
}
