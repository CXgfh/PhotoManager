//
//  UIColor+Random.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIColor {
    static var random: UIColor {
        let red: CGFloat = CGFloat.random(in: 0...1)
        let green: CGFloat = CGFloat.random(in: 0...1)
        let blue: CGFloat = CGFloat.random(in: 0...1)
        let alpha: CGFloat = CGFloat.random(in: 0...1)
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
