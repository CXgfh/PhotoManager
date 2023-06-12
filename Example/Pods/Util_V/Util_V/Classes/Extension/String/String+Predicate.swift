//
//  String+Predicate.swift
//  Vick_Util
//
//  Created by Vick on 2022/6/1.
//

import Foundation

public extension String {
    ///检测合法URL
    var isValidURL: Bool {
        let rules = NSPredicate(format: "SELF MATCHES %@", "((http|https)://)?((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+")
        return rules.evaluate(with: self)
    }
    
    ///是否是手机号
    var isMobileNumber: Bool {
        /*
         手机号码:
         13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
         移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
         联通号段: 130,131,132,155,156,185,186,145,176,1709
         电信号段: 133,153,180,181,189,177,1700
         */
        let mobile = "^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|70)\\d{8}$"
        /*
         中国移动：China Mobile
         134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
         */
        let cm = "(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)"
        /*
         中国联通：China Unicom
         130,131,132,155,156,185,186,145,176,1709
         */
        let cu = "(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)"
        /*
          中国电信：China Telecom
          133,153,180,181,189,177,1700
         */
        let ct = "(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)"
        
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@", mobile)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@", cm)
        let regextestcu = NSPredicate(format: "SELF MATCHES %@", cu)
        let regextestct = NSPredicate(format: "SELF MATCHES %@", ct)
        
        if regextestmobile.evaluate(with: self) || regextestcm.evaluate(with: self) || regextestcu.evaluate(with: self) || regextestct.evaluate(with: self) {
            return true
        } else {
            return false
        }
    }
}
