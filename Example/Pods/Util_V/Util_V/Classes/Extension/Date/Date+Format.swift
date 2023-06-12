//
//  DateFormatter.swift
//  Countdown
//
//  Created by flow on 2020/10/27.
//

import Foundation

//MARK: -时间显示
public extension Date {
    /*      完整格式
     年      yyyy
     月      MM
     日      dd
     星期    EEEE (完整格式星期几、省略模式周几)
     时      HH
     分      mm
     秒      ss
     毫秒    SSS
     上下午   aa
     时区     ZZZZ
     */
    
    var timeString: String {
        let dateF = DateFormatter()
        dateF.dateFormat = "HH:mm"
        dateF.locale = .init(identifier: identifier)
        return dateF.string(from: self)
    }
    
    var weekString: String {
        let dateF = DateFormatter()
        dateF.dateFormat = "EEEE"
        dateF.locale = .init(identifier: identifier)
        return dateF.string(from: self)
    }
    
    var monthString: String {
        let dateF = DateFormatter()
        dateF.dateFormat = "EEEE,MM,dd"
        dateF.locale = .init(identifier: identifier)
        return dateF.string(from: self)
    }
    
    var yearString: String {
        let dateF = DateFormatter()
        dateF.dateFormat = "yyyy/MM/dd EEEE"
        dateF.locale = .init(identifier: identifier)
        return dateF.string(from: self)
    }
    
    func makeString(by: String) -> String {
        let dateF = DateFormatter()
        dateF.dateFormat = by
        dateF.locale = .init(identifier: identifier)
        return dateF.string(from: self)
    }
}



