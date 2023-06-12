//
//  UITableView+Register.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UITableView {
    func register(_ cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(withCellClass cellClass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellClass)
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T
    }
}
