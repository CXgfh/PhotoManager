//
//  CMTime.swift
//  TypeFormatter
//
//  Created by Vick on 2022/9/23.
//

import UIKit
import AVKit

public extension CMTime {
    ///转化为时长
    var mediaTime: String {
        return CMTimeGetSeconds(self).mediaTime
    }
    
    ///转化为百分比进度
    func multipliedBy(_ total: CMTime) -> Double {
        return CMTimeGetSeconds(self) / CMTimeGetSeconds(total)
    }
}
