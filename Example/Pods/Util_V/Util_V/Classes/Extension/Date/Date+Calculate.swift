//
//  Date+Calculate.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation

//计算时间间隔
public extension Date {
    ///计算天数from: date, to: self
    func calculateDays(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    ///计算周数from: date, to: self
    func calculateWeeks(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    
    ///计算月数from: date, to: self
    func calculateMonths(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    ///计算年数from: date, to: self
    func calculateYears(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
}


