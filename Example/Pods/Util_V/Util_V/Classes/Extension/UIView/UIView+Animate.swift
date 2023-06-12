//
//  UIView+Animate.swift
//  Vick_Util
//
//  Created by Vick on 2022/4/13.
//

import UIKit

public extension UIView {
    ///视图抖动； isHorizontal：抖动方向，times：抖动次数，interval：每次抖动时间，delta：抖动偏移量
    func shake(isHorizontal: Bool = true, times: Int = 2, interval: TimeInterval = 0.1, delta: CGFloat = 2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: interval, animations: { () -> Void in
            if isHorizontal {
                self.layer.setAffineTransform(CGAffineTransform(translationX: delta, y: 0))
            } else {
                self.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: delta))
            }
        }) { (complete) -> Void in
            if (times == 0) {
                UIView.animate(withDuration: interval, animations: { () -> Void in
                    self.layer.setAffineTransform(CGAffineTransform.identity)
                }, completion: { (complete) -> Void in
                    completion?()
                })
            }
            else {
                self.shake(times: times - 1,  interval: interval, delta: delta * -1, completion:completion)
            }
        }
    }
    
    ///无限抖动；isHorizontal：抖动方向，interval：每次抖动时间，delta：抖动偏移量
    func keepShake(isHorizontal: Bool = true, interval: TimeInterval = 0.1, delta: CGFloat = 2, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: interval, animations: { () -> Void in
            if isHorizontal {
                self.layer.setAffineTransform(CGAffineTransform(translationX: delta, y: 0))
            } else {
                self.layer.setAffineTransform(CGAffineTransform(translationX: 0, y: delta))
            }
        }) { (complete) -> Void in
            self.keepShake(isHorizontal: isHorizontal, interval: interval, delta: delta * -1, completion: completion)
        }
    }
}
