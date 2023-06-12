//
//  Int64.swift
//  TypeFormatter
//
//  Created by Vick on 2022/9/23.
//

import UIKit

public extension Int64 {
    var byte: String {
        let formatter: ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}
