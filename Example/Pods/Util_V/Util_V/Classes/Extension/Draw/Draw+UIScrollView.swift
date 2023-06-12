//
//  UIScrollView.swift
//  
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIScrollView {
    ///长截图
    var captureScrollView: UIImage? {
        var image: UIImage? = nil
        let savedContentOffset = contentOffset
        let savedFrame = frame
        contentOffset = .zero

        frame = CGRect(x: 0, y: 0,
                       width: contentSize.width,
                       height: contentSize.height)
        UIGraphicsBeginImageContext(frame.size)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: frame.size.width, height: frame.size.height), false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        contentOffset = savedContentOffset
        frame = savedFrame
        return image
    }
}


