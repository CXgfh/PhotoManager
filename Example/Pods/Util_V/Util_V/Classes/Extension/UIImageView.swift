//
//  UIImageView.swift
//  Util
//
//  Created by V on 2022/11/11.
//

import UIKit

public extension UIImageView {
    ///获取image在UIImageView的bounds
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let widthScale = bounds.width / image.size.width
        let heightScale = bounds.height / image.size.height
        let scale = widthScale > heightScale ? heightScale : widthScale
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
