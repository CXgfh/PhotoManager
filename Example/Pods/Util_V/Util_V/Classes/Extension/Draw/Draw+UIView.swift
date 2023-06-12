//
//  UIView+Draw.swift
//  Vick_Custom
//
//  Created by Vick on 2022/9/1.
//

import UIKit

public extension UIView {
    var captureView: UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

