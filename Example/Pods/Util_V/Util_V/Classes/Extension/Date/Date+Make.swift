//
//  Date+Make.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

//生成特定时间
public extension Date {
    ///生成指定时刻
    func specifiedTime(_ date: Date) -> Date {
        let dateF = DateFormatter()
        dateF.locale = .init(identifier: identifier)
        dateF.dateFormat = "yyyy-MM-dd"
        var tem = dateF.string(from: self)
        dateF.dateFormat = "HH:mm"
        let time = dateF.string(from: date)
        tem += " "
        tem += time
        tem += ":00"
        dateF.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateF.date(from: tem) ?? Date()
    }
    
    func specifiedDay(_ days: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.day = days
        return calendar.date(byAdding: components, to: self) ?? Date()
    }
    
    func specifiedWeek(_ weeks: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.weekOfYear = weeks
        return calendar.date(byAdding: components, to: self) ?? Date()
    }
    
    func specifiedMonth(_ month: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = month
        return calendar.date(byAdding: components, to: self) ?? Date()
    }
    
    func specifiedYear(_ year: Int) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        return calendar.date(byAdding: components, to: self) ?? Date()
    }
}
