//
//  PikerModel.swift
//  PhotoManager
//
//  Created by V on 2023/2/24.
//

import UIKit



public enum PhotoManagerPPI: CaseIterable {
    case original
    case _1080
    case _720
    case _480
    case CIF
    
    var title: String {
        switch self {
        case .original:
            return "原始尺寸"
        case ._1080:
            return "1080P"
        case ._720:
            return "720P"
        case ._480:
            return "480P"
        case .CIF:
            return "CIF"
        }
    }
    
    var size: CGSize {
        switch self {
        case .original:
            return .zero
        case ._1080:
            return CGSize(width: 1920, height: 1080)
        case ._720:
            return CGSize(width: 1080, height: 720)
        case ._480:
            return CGSize(width: 720, height: 480)
        case .CIF:
            return CGSize(width: 355, height: 288)
        }
    }
}
