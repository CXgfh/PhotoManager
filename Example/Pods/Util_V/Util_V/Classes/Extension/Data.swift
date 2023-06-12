//
//  Data.swift
//  Util_V
//
//  Created by V on 2023/4/10.
//

import Foundation

public extension Data {
    var htmlToString: String? {
        let cfEncoding = CFStringEncodings.GB_18030_2000
        let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEncoding.rawValue))
        
        if let str = String(data: self, encoding: .utf8) {
            return str
        } else if let str = NSString(data: self, encoding: encoding) {
            //GBK编码
            return str as String
        } else {
            return nil
        }
    }
}
