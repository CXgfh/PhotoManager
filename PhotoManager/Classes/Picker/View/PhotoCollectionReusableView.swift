//
//  PhotoCollectionReusableView.swift
//  PhotoManager
//
//  Created by V on 2023/6/1.
//

import UIKit
import SnapKit
import Util_V

class PhotoCollectionReusableView: UICollectionReusableView {
    
    var title: String? {
        didSet {
            label.text = title
        }
    }
    
    private lazy var label: UILabel = {
        let label =  UILabel(font: .systemFont(ofSize: 14, weight: .regular), textColor: UIColor(photo: "picker_text_color")!)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
