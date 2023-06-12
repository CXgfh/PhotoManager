//
//  BaseNavigationBarWrapper.swift
//  BaseNavigationBar
//
//  Created by Vick on 2022/10/24.
//

import UIKit

public class BaseNavigationBarWrapper<Base> {
    var base: Base
    
    init(_ base: Base) {
        self.base = base
    }
}

public extension BaseNavigationBarWrapper where Base: UIViewController {
    func changedTranslucent(isTranslucent: Bool) {
        base.navigationController?.navigationBar.isTranslucent = isTranslucent
    }
    
    func setTintColor(color: UIColor) {
        base.navigationController?.navigationBar.tintColor = color
    }
    
    func setTitleStyle(attributed: [NSAttributedString.Key : Any]?) {
        base.navigationController?.navigationBar.titleTextAttributes = attributed
    }
    
    func setBackground(image: UIImage?, color: UIColor, effect: UIBlurEffect? = nil) {
        if #available(iOS 13, *) {
            let appearance =  base.navigationController?.navigationBar.standardAppearance ?? UINavigationBarAppearance()
            appearance.backgroundImage = image
            appearance.backgroundColor = color
            appearance.backgroundEffect = effect
            base.navigationController?.navigationBar.standardAppearance = appearance
            setScrollEdgeAppearance(appearance: appearance)
        } else {
            base.navigationController?.navigationBar.setBackgroundImage(image, for: .default)
            base.navigationController?.navigationBar.backgroundColor = color
        }
    }
    
    func setShadow(image: UIImage?, color: UIColor = .clear) {
        if #available(iOS 13, *) {
            base.navigationController?.navigationBar.standardAppearance.shadowImage = image
            base.navigationController?.navigationBar.standardAppearance.shadowColor = color
        } else {
            base.navigationController?.navigationBar.shadowImage = image
        }
    }
    
    @available(iOS 13.0, *)
    func setScrollEdgeAppearance(appearance: UINavigationBarAppearance?) {
        base.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
}
