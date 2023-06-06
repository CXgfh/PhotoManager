//
//  SelectButton.swift
//  PhotoManager
//
//  Created by V on 2023/5/24.
//

import UIKit

class SelectButton: UIButton {

    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor(hex: 0x0097D6) : UIColor(hex: 0x232323)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        layer.cornerRadius = 10
        backgroundColor = UIColor(hex: 0x232323)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
