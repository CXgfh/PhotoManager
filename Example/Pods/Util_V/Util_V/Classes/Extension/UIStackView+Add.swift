//
//  UIStackView+Add.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UIStackView {
    func addArrangedSubviews(_ subviews: UIView...) {
        for index in subviews {
            self.addArrangedSubview(index)
        }
    }
}
