//
//  String+Encoded.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

//MARK: -编码
public extension String {
    ///base64编码
    var toBase64: String {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    ///base64解码
    var fromBase64: String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    ///解析html格式
    var fromHtml: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
}
