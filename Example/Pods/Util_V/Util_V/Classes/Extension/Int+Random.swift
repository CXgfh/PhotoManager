//
//  Int+Random.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension Int {
    ///随机一个数 0～abs（self）
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32((self*1000)/1000)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs((self*1000))/1000)))
        } else {
            return 0
        }
    }
}
