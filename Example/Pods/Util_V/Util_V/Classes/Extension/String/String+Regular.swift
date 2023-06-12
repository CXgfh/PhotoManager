//
//  String+Regular.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

public extension String {
    ///指定字符
    @discardableResult
    func match(_ string: String) -> [NSRange] {
        var selfStr = self as NSString
        var withStr = Array(repeating: "X", count: (string as NSString).length).joined(separator: "") //辅助字符串
        if string == withStr { withStr = withStr.lowercased() } //临时处理辅助字符串差错
        var allRange = [NSRange]()
        while selfStr.range(of: string).location != NSNotFound {
            let range = selfStr.range(of: string)
            allRange.append(NSRange(location: range.location,length: range.length))
            selfStr = selfStr.replacingCharacters(in: NSMakeRange(range.location, range.length), with: withStr) as NSString
        }
        return allRange
    }
    
    func regular(_ pattern: String) -> [NSTextCheckingResult] {
        do {
            return try NSRegularExpression(pattern: pattern, options: .caseInsensitive).matches(in: self, range: NSRange(location: 0, length: (self as NSString).length))
        } catch {
            debugPrint(error)
            return []
        }
    }
}
