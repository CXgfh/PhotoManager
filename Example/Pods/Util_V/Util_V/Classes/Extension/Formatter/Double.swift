//
//  Double.swift
//  TypeFormatter
//
//  Created by Vick on 2022/9/23.
//

import UIKit

public extension Double {
    var mediaTime: String {
        let intTime = Int(self+0.5)
        
        let hours = intTime / 3600
        let minutes = (intTime / 60) % 60
        let seconds = intTime % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
