//
//  Util+Screen.swift
//  Util
//
//  Created by Vick on 2022/9/29.
//

import UIKit

public extension Util {
    static var screen: UIScreen {
        if #available(iOS 13.0, *) {
            return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen ?? .init()
        } else {
            return UIScreen.main
        }
    }
}



public func findTopViewController(_ viewController: UIViewController?) -> UIViewController? {
    var top: UIViewController?
    if viewController == nil {
        top = keyWindow()?.rootViewController
    } else {
        top = viewController
    }
    while true {
        if let presented = top?.presentedViewController {
            top = presented
        } else if let nav = top as? UINavigationController {
            top = nav.visibleViewController
        } else if let tab = top as? UITabBarController {
            top = tab.selectedViewController
        } else {
            break
        }
    }
    return top
}

public func keyWindow() -> UIWindow? {
    var originalKeyWindow: UIWindow?

    #if swift(>=5.1)
    if #available(iOS 13, *) {
        originalKeyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    } else {
        originalKeyWindow = UIApplication.shared.keyWindow
    }
    #else
    originalKeyWindow = UIApplication.shared.keyWindow
    #endif
    
    return originalKeyWindow
}

