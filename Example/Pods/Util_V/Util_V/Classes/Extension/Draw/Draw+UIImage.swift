//
//  UIImage.swift
//  
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIImage {
    ///灰度图片
    var gray: UIImage? {
        guard let imageRef = self.cgImage else {
            return nil
        }
        let width: Int = imageRef.width
        let height: Int = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        guard let context: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let outPutImage: CGImage = context.makeImage() else {
            return nil
        }
        return UIImage(cgImage: outPutImage)
    }
    
    ///左右镜像
    var flip: UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.scaleBy(x: -1, y: 1)
        ctx?.translateBy(x: -self.size.width, y: 0)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 图片染色
    func dyeing(by color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        color.set()
        UIRectFillUsingBlendMode(rect, .sourceAtop)
        let tintImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return tintImage
    }
    
    /// 缩放
    func zoom(multiple: CGFloat,
              scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let newSize = CGSize(width:self.size.width * multiple,
                             height:self.size.height * multiple)
        return zoom(size: newSize, scale: scale)
    }
    
    /// 缩放
    func zoom(size: CGSize,
              scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size,
                                               false,
                                               scale)
        draw(in: CGRect(x: 0,
                        y: 0,
                        width: size.width,
                        height:size.height))
        let new = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new
    }
    
    ///增加边距
    func newSize(insets: UIEdgeInsets,
                 scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let contentSize = CGSize(width: size.width + insets.left + insets.right,
                                 height: size.height + insets.top + insets.bottom)
        
        UIGraphicsBeginImageContextWithOptions(contentSize,
                                               false,
                                               scale)
        draw(in: CGRect(x: insets.left,
                        y: insets.top,
                        width: size.width,
                        height:size.height))
        let new = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new
    }
    
    /// 裁剪图片
    func tailor(by rect: CGRect) -> UIImage? {
        var new = rect
        new.origin.x *= self.scale
        new.origin.y *= self.scale
        new.size.width *= self.scale
        new.size.height *= self.scale
        guard let cgimage = self.cgImage?.cropping(to: new) else {
            return nil
        }
        return UIImage(cgImage: cgimage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    ///生成旋转后的图片
    func rotate(by angle: CGFloat, at size: CGSize? = nil) -> UIImage? {
        let contentSize = size ?? self.size
        var newSize = CGRect(origin: CGPoint.zero,
                             size: contentSize).applying(CGAffineTransform(rotationAngle: CGFloat(angle))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize,
                                               false,
                                               UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.translateBy(x: newSize.width/2,
                            y: newSize.height/2)
        context.rotate(by: angle)
        
        draw(in: CGRect(x: -contentSize.width/2,
                        y: -contentSize.height/2,
                        width: contentSize.width,
                        height: contentSize.height))
        let new = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new
    }
    
    ///图片拉伸：点九图
    func stretch(by color: UIColor? = nil, with capInsets: UIEdgeInsets) -> UIImage {
        if let color = color {
            return self.dyeing(by: color).resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        } else {
            return self.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
        }
    }
    
    ///圆角
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(UIBezierPath(roundedRect: rect,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: radius, height: radius)).cgPath)
        context.clip()
        self.draw(in: rect)
        context.drawPath(using: .fillStroke)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    ///压缩图片
    func compressImage() -> UIImage? {
        var height: CGFloat
        var width: CGFloat
        if self.size.width > self.size.height {
            height = self.size.width
            width = self.size.height
        } else {
            height = self.size.height
            width = self.size.width
        }
        
        if height > 1280 || width > 720 {
            let heightScale = 1280 / height
            let widthScale = 720 / width
            let scale = heightScale > widthScale ? heightScale : widthScale
            return zoom(multiple: scale)
        }
        return self
    }
}
