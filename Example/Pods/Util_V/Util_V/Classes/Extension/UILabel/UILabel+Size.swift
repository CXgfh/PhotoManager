//
//  UILabel.swift
//  Util
//
//  Created by V on 2022/11/11.
//

import UIKit

public extension UILabel {
    ///获取Label实际字体大小
    var getRealFontSize: CGFloat {
        if let attributedString = self.attributedText, let font = self.font {
            let text = NSMutableAttributedString(attributedString: attributedString)
            text.setAttributes([NSAttributedString.Key.font: font], range: NSRange(location: 0, length: attributedString.length))
            let context = NSStringDrawingContext()
            context.minimumScaleFactor = self.minimumScaleFactor
            text.boundingRect(with: self.frame.size, options: .usesLineFragmentOrigin, context: context)
            return self.font.pointSize * context.actualScaleFactor
        }
        return self.font.pointSize
    }
}
