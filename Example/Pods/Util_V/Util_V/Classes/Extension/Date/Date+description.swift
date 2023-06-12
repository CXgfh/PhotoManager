//
//  Date.swift
//  Util
//
//  Created by V on 2023/2/19.
//

import UIKit

public extension Date {
    var messageTime: String {
        var extra = ""
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: identifier)
        let dateComponents =  Calendar.current.dateComponents([.year, .month, .day], from: self, to: Date())
        if let year = dateComponents.year, year == 0 {
            if let month = dateComponents.month, month == 0 {
                if let day = dateComponents.day {
                    switch day {
                    case 0:
                        formatter.dateFormat = "HH:mm"
                    case 1:
                        extra = "昨天"
                        formatter.dateFormat = "HH:mm"
                    default:
                        formatter.dateFormat = "EEEE HH:mm"
                    }
                }
            } else {
                formatter.dateFormat = "MM HH:mm"
            }
        } else {
            formatter.dateFormat = "yyyy MMM dd"
        }
        
        return extra + formatter.string(from: self)
    }
}
