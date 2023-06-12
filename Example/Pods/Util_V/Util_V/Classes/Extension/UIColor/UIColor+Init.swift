//
//  UIColor+Init.swift
//  Util
//
//  Created by Vick on 2022/9/20.
//

import UIKit

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: a)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: (hex >> 16) & 0xff,
                  green: (hex >> 8) & 0xff,
                  blue: hex & 0xff,
                  a: alpha)
    }
    
    convenience init(hex: Int, darkHex: Int, alpha: CGFloat = 1.0) {
        if #available(iOS 13.0, *),
           UITraitCollection.current.userInterfaceStyle == .dark {
            self.init(red: (darkHex >> 16) & 0xff,
                             green: (darkHex >> 8) & 0xff,
                             blue: darkHex & 0xff,
                             a: alpha)
        } else {
            self.init(red: (hex >> 16) & 0xff,
                      green: (hex >> 8) & 0xff,
                      blue: hex & 0xff,
                      a: alpha)
        }
    }
}
