//
//  UIButton.swift
//  Util
//
//  Created by V on 2023/3/14.
//

import UIKit

public extension UIButton {
    convenience init(title: String,
                     titleColor: UIColor,
                     font: UIFont) {
        self.init()
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = font
    }
    
    convenience init(image: UIImage?) {
        self.init()
        setImage(image, for: .normal)
    }
    
    convenience init(image: UIImage?,
                     title: String,
                     titleColor: UIColor,
                     font: UIFont) {
        self.init(title: title, titleColor: titleColor, font: font)
        setImage(image, for: .normal)
    }
}
