//
//  UILabel+Init.swift
//  Util
//
//  Created by V on 2023/3/14.
//

import UIKit

public extension UILabel {
    convenience init(font: UIFont,
                     textColor: UIColor,
                     textAlignment: NSTextAlignment = .left) {
        self.init()
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
    }
}
