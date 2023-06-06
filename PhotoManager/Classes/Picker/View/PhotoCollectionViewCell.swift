//
//  PhotoCollectionViewCell.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/27.
//

import UIKit
import Util_V
import Photos
import SnapKit
import ContentSizeView

class PhotoCollectionViewCell: UICollectionViewCell {
    
    var model: AlbumAsset? {
        didSet {
            if let model = model {
                sizeLabel.isHidden = model.size == 0
                sizeLabel.text = model.size.byte
                
                timeLabel.isHidden = model.asset.duration == 0
                timeLabel.text = model.asset.duration.mediaTime
                
                model.asset.getImage(by: self.size, deliveryMode: .opportunistic) { image, info in
                    self.assetImageView.image = image
                }
            }
        }
    }
    
    var chooseIndex: Int = -1 {
        didSet {
            if chooseIndex == -1 {
                chooseView.isHidden = true
            } else {
                chooseView.isHidden = false
                chooseNumber.text = (chooseIndex + 1).description
            }
        }
    }
    
    private lazy var assetImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var dimmingView: GradientViewOfQuadrilateral = {
        let v = GradientViewOfQuadrilateral(direction: .diagonal)
        v.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor
        ]
        v.locations = [0.3, 1]
        return v
    }()
    
    private lazy var messageStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        stack.addArrangedSubviews(timeLabel, sizeLabel)
        return stack
    }()
    
    private lazy var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private lazy var chooseView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var chooseNumber: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 15, weight: .regular), textColor: .white)
        return label
    }()
    
    private lazy var chooseImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(photo: "picker_checkmark.circle")?.dyeing(by: UIColor(photo: "picker_theme_color_1")!)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoCollectionViewCell {
    private func setupUI() {
        self.backgroundColor = .white
        self.addSubviews(assetImageView, dimmingView, messageStackView, chooseView)
        assetImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dimmingView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(24)
        }
        
        messageStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(dimmingView)
            make.right.equalTo(dimmingView).offset(-8)
        }
        
        chooseView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        chooseView.addSubviews(chooseImageView, chooseNumber)
        chooseImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.right.bottom.equalTo(chooseView).inset(8)
        }
        
        chooseNumber.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(8)
        }
    }
}
