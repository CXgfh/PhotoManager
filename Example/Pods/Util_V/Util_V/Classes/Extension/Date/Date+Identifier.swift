//
//  Date+Identifier.swift
//  VDate
//
//  Created by Vick on 2022/9/14.
//

import Foundation

extension Date {
    internal var identifier: String {
        switch Bundle.main.preferredLocalizations.first {
        case "en":
            return "en_US"
        case "ja":
            return "ja_JP"
        default:
            return "zh_CN"
        }
    }
}
