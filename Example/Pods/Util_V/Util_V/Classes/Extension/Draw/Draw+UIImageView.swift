//
//  UIImageView.swift
//  Logo Maker
//
//  Created by Frank on 2021/5/17.
//

import UIKit

public extension UIImageView {
    ///将UIImageView绘制成图片, 可以处理背景透明
    var captureImageView: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
}
