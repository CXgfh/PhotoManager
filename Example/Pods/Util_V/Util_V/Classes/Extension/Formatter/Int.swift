//
//  Int.swift
//  TypeFormatter
//
//  Created by Vick on 2022/9/23.
//

import UIKit

public extension Int {
    var arabicNumerals: String {
        let format = NumberFormatter()
        format.locale = Locale(identifier: "zh_CN")
        format.numberStyle = .spellOut
        format.minimumIntegerDigits = 1
        format.minimumFractionDigits = 0
        format.maximumFractionDigits = 2
        return format.string(from: NSNumber(value: self)) ?? ""
    }
    
    ///添加数字分隔符
    func makeSeparated(group: Int = 3, separator: Character = ",") -> String {
        return makeSeparated(text: String(self), group, separator)
    }
    
    private func makeSeparated(text: String, _ groupCount: Int, _ symbol: Character) -> String {
        var temp = text
        let count = temp.count
        let sepNum = count / groupCount
        guard sepNum >= 1 else {
            return temp
        }
        for i in 1...sepNum {
            let index = count - groupCount * i
            guard index != 0 else {
                break
            }
            temp.insert(symbol, at: temp.index(temp.startIndex, offsetBy: index))
        }
        return temp
    }
}
