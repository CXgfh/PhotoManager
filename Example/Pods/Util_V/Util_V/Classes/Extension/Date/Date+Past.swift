//
//  Date+Calculate.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

//过去特定时间
public extension Date {
    ///当天凌晨0点
    var zeroTime: Date {
        let dateF = DateFormatter()
        dateF.locale = .init(identifier: identifier)
        dateF.dateFormat = "yyyy-MM-dd"
        var tem = dateF.string(from: self)
        dateF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        tem += " 00:00:00"
        return dateF.date(from: tem) ?? Date()
    }
    
    ///本周周日
    var thisSunday: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? Date()
    }
    
    ///本月
    var thisMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: self)
        return calendar.date(from: components) ?? Date()
    }
    
    ///今年
    var thisYear: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: self)
        return calendar.date(from: components) ?? Date()
    }
}
