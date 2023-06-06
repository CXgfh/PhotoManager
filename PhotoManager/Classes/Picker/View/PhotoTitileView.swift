//
//  PhotoTitileView.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/29.
//

import UIKit
import Util_V

class PhotoTitileView: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    private var layoutCenterX: NSLayoutConstraint?
    
    private(set) var isOpenMenu = false
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        stack.addArrangedSubviews(titleLabel, indicatorImageView)
        return stack
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(photo: "picker_text_color")
        return label
    }()
    
    private lazy var indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(photo: "picker_title")
        return imageView
    }()
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews(stackView)
        NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if layoutCenterX == nil {
            layoutCenterX = NSLayoutConstraint(item: stackView, attribute: .centerX, relatedBy: .equal, toItem: self.superview?.superview, attribute: .centerX, multiplier: 1, constant: 0)
        }
        layoutCenterX?.isActive = true
    }
}

extension PhotoTitileView {
    public func changedIndicator() {
        isOpenMenu = !isOpenMenu
        UIView.animate(withDuration: 0.17) {
            if self.isOpenMenu {
                self.indicatorImageView.transform = .init(rotationAngle: .pi)
            } else {
                self.indicatorImageView.transform = .identity
            }
        }
    }
}
