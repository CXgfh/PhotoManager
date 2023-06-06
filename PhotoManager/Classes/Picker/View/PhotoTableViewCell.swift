//
//  PhotoTableViewCell.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/29.
//

import UIKit
import Util_V

class PhotoTableViewCell: UITableViewCell {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(photo: "picker_text_color")
        return label
    }()
   

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoTableViewCell {
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubviews(titleLabel)
        
        NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 24).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
}
