//
//  String+Attributed.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import Foundation
import UIKit

//MARK: -富文本
public extension String {
    ///lineHeight行高,lineSpacing行间距,kernSpacing字间距
    func attributedString(color: UIColor = .white, font: UIFont, lineHeight: CGFloat? = nil, lineSpacing: CGFloat? = nil, kernSpacing: CGFloat? = nil) -> NSMutableAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        if let height = lineHeight {
            paragraphStyle.maximumLineHeight = height
            paragraphStyle.minimumLineHeight = height
        }
        if let spacing = lineSpacing {
            paragraphStyle.lineSpacing = spacing
        }
        let attributedString = NSMutableAttributedString(string: self, attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: color, .font: font])
        if let kern = kernSpacing {
            attributedString.addAttributes([.kern: kern], range: NSRange(location: 0, length: (self as NSString).length))
        }
        return attributedString
    }
}

public extension NSMutableAttributedString {
    func text(_ color: UIColor, font: UIFont? = nil, paragraphStyle: NSMutableParagraphStyle? = nil, _ range: NSRange) {
        self.addAttributes([.foregroundColor: color], range: range)
        if let font = font {
            self.addAttributes([.font: font], range: range)
        }
        if let paragraphStyle = paragraphStyle {
            self.addAttributes([.paragraphStyle: paragraphStyle], range: range)
        }
    }
}
