//
//  Date+Belong.swift
//  VDate
//
//  Created by Vick on 2022/9/14.
//

import Foundation

//today、yesterday、week 同级
public enum DateBelong {
    case minute(_ value: Int)
    case hour
    case today
    case yesterday
    case week
    case month
    case year
    case far
}

public extension Date {
    ///from: date, to: self
    func belong(_ date: Date) -> DateBelong {
        var result = DateBelong.far
        let dateComponents =  Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .minute], from: date, to: self)
        if let year = dateComponents.year, year == 0 {
            result = .year
            if let month = dateComponents.month, month == 0 {
                result = .month
                if let week = dateComponents.weekOfYear, week == 0 {
                    result = .week
                }
                if let day = dateComponents.day {
                    switch day {
                    case 0:
                        result = .today
                        if let minute = dateComponents.minute {
                            switch minute {
                            case 0...59:
                                result = .minute(minute)
                            default:
                                result = .hour
                            }
                        }
                    case 1:
                        result = .yesterday
                    default:
                        break
                    }
                }
            }
        }
        return result
    }
}
