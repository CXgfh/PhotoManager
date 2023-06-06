//
//  Util.swift
//  ContentSizeView
//
//  Created by V on 2023/2/16.
//

import UIKit

internal func newSize(_ size: CGSize, edge: UIEdgeInsets) -> CGSize {
    return CGSize(width: size.width+edge.left+edge.right,
                  height: size.height+edge.top+edge.bottom)
}
