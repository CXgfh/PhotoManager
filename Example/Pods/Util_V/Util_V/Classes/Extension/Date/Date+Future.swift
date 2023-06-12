//
//  Date+Future.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

//未来特定时间
public extension Date {
    ///明天凌晨0点
    var nextDay: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 1
        return calendar.date(byAdding: components, to: self.zeroTime) ?? Date()
    }
    
    ///本周六
    var saturday: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = 6
        return calendar.date(byAdding: components, to: self.thisSunday) ?? Date()
    }
    
    ///下个月
    var nextMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        return calendar.date(byAdding: components, to: self.thisMonth) ?? Date()
    }
    
    ///明年
    var nextYear: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1
        return calendar.date(byAdding: components, to: self.thisYear) ?? Date()
    }
}
