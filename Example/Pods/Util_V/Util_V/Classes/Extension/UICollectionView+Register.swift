//
//  UICollectionView+Register.swift
//  Util
//
//  Created by Vick on 2022/9/21.
//

import UIKit

public extension UICollectionView {
    func register(_ cellClass: AnyClass) {
        let identifier = String(describing: cellClass)
        register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(withCellClass cellClass: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellClass)
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! T
    }
}
