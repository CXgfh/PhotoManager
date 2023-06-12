//
//  Date+Constellation.swift
//  VDate
//
//  Created by Vick on 2022/10/25.
//

import UIKit

public enum Constellation {
    case Aries //白羊座 3月21日~4月19日
    case Taurus //金牛座 4月20日～5月20日
    case Gemini //双子座 5月21日～6月21日
    case Cancer //巨蟹座 6月22日～7月22日
    case Leo //狮子座 7月23日～8月22日
    case Virgo //处女座 8月23日～9月22日
    case Libra //天秤座 9月23日～10月23日
    case Scorpio //天蝎座 10月24日～11月22日
    case Sagittarius //射手座 11月23日～12月21日
    case Capricorn //摩羯座 12月22日～1月19日
    case Aquarius //水瓶座 1月20日～2月18日
    case Pisces //双鱼座 2月19日～3月20日
    case Unkown
}

public extension Date {
    var constellation: Constellation {
        let dateF = DateFormatter()
        dateF.dateFormat = "MM-dd"
        dateF.locale = .init(identifier: identifier)
        let result = dateF.string(from: self).components(separatedBy: "-")
        let month = Int(result[0]) ?? 0
        let day = Int(result[1]) ?? 0
        switch month {
        case 1:
            if day <= 19 {
                return .Capricorn
            }
            return .Aquarius
        case 2:
            if day <= 18 {
                return .Aquarius
            }
            return .Pisces
        case 3:
            if day <= 20 {
                return .Pisces
            }
            return .Aries
        case 4:
            if day <= 19 {
                return .Aries
            }
            return .Taurus
        case 5:
            if day <= 20 {
                return .Taurus
            }
            return .Gemini
        case 6:
            if day <= 21 {
                return .Gemini
            }
            return .Cancer
        case 7:
            if day <= 22 {
                return .Cancer
            }
            return .Leo
        case 8:
            if day <= 22 {
                return .Leo
            }
            return .Virgo
        case 9:
            if day <= 22 {
                return .Virgo
            }
            return .Libra
        case 10:
            if day <= 23 {
                return .Libra
            }
            return .Scorpio
        case 11:
            if day <= 22 {
                return .Scorpio
            }
            return .Sagittarius
        case 12:
            if day <= 21 {
                return .Sagittarius
            }
            return .Capricorn
        default:
            return .Unkown
        }
    }
}
