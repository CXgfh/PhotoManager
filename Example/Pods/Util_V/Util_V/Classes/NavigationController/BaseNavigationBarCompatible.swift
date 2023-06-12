//
//  BaseNavigationBarCompatible.swift
//  BaseNavigationBar
//
//  Created by Vick on 2022/10/24.
//

import UIKit


public protocol BaseNavigationBarCompatible {
    associatedtype BaseNavigationBarCompatibleType
    var navigationBar: BaseNavigationBarCompatibleType { get }
}

public extension BaseNavigationBarCompatible {
    var navigationBar: BaseNavigationBarWrapper<Self> {
        return BaseNavigationBarWrapper(self)
    }
}

extension UIViewController: BaseNavigationBarCompatible { }
