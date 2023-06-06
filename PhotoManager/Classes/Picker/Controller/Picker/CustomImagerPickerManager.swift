//
//  CustomImagerPickerManager.swift
//  PhotoManager
//
//  Created by V on 2023/4/18.
//

import UIKit
import Photos
import ContentSizeView
import SnapKit

protocol CustomImagerPickerManagerDelegate: AnyObject {
    func startPicker()
    func startDel()
    func endedCatch(_ result: [Any])
}

class CustomImagerPickerManager: NSObject {
    
    var isPicking: Bool {
        return false
    }
    
    private weak var delegate: CustomImagerPickerManagerDelegate!
    
    private var catchAssets = [Any?]()
    private var catchCount = 0 {
        didSet {
            if catchCount == selectedCount {
                let tem = catchAssets.compactMap{ $0 }
                delegate.endedCatch(tem)
            }
        }
    }
    
    private var selectedIndexs = [IndexPath]()
    private var selectedAssets = [IndexPath: PHAsset]()
    private var selectedCount = 0 {
        didSet {
            promptLabel.text = "已选中" + selectedCount.description + "个资源"
            chooseStackView.alpha = selectedCount == 0 ? 0 : 1
        }
    }
    
    private lazy var chooseStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 8
        stack.addArrangedSubviews(promptLabel, chooseButton, delButton)
        
        chooseButton.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
        
        delButton.snp.makeConstraints { make in
            make.width.equalTo(44)
        }
        
        stack.alpha = 0
        return stack
    }()
    
    private lazy var promptLabel: ContentSizeOfLabel = {
        let label = ContentSizeOfLabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(photo: "picker_text_color")
        label.backgroundColor = UIColor(photo: "picker_theme_color_1")
        label.maxCornerRadius = 20
        label.titleEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        return label
    }()
    
    private lazy var chooseButton: ContentSizeOfButton = {
        let button = ContentSizeOfButton()
        button.setImage(UIImage(photo: "picker_paperplane"), for: .normal)
        button.maxCornerRadius = 8
        button.backgroundColor = UIColor(photo: "picker_theme_color_1")
        button.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(chooseTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var delButton: ContentSizeOfButton = {
        let button = ContentSizeOfButton()
        button.setImage(UIImage(photo: "picker_trash"), for: .normal)
        button.maxCornerRadius = 8
        button.backgroundColor = UIColor(photo: "picker_theme_color_1")
        button.imageEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(delTap), for: .touchUpInside)
        return button
    }()
    
    init(by view: UIView, delegate: CustomImagerPickerManagerDelegate) {
        super.init()
        self.delegate = delegate
        PhotoManager.sharde.delegate.add(self)
        
        view.addSubview(chooseStackView)
        chooseStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension CustomImagerPickerManager {
    @objc private func chooseTap() {
        delegate.startPicker()
        let phAssets = selectedIndexs.map{ selectedAssets[$0] }.compactMap{ $0 }
        catchAssets = [Any?](repeating: nil, count: selectedCount)
        catchCount = 0
        for index in phAssets.indices {
            switch phAssets[index].mediaType {
            case .video:
                phAssets[index].getURL { url in
                    if let url = url {
                        self.catchAssets[index] = url
                        self.catchCount += 1
                    } else {
                        self.catchCount += 1
                    }
                }
            case .image:
                phAssets[index].getImage { image, info in
                    self.catchAssets[index] = image
                    self.catchCount += 1
                }
            default:
                self.catchAssets[index] = phAssets[index]
                self.catchCount += 1
            }
            
        }
    }
    
    @objc private func delTap() {
        delegate?.startDel()
        var tem = [PHAsset]()
        for (_, value) in selectedAssets {
            tem.append(value)
        }
        PhotoManager.sharde.delAssetAtAlbums(tem)
    }
}

extension CustomImagerPickerManager {
    func clear() {
        selectedIndexs = []
        selectedAssets = [:]
        selectedCount = 0
    }
    
    func picker(_ max: Int, index: IndexPath, asset: PHAsset) {
        var flag = false
        for (key, value) in selectedIndexs.reversed().enumerated() {
            if value == index {
                flag = true
                selectedIndexs.remove(at: key)
                selectedAssets[index] = nil
            }
        }
        if flag {
            selectedCount -= 1
        } else if selectedCount < max {
            selectedCount += 1
            selectedIndexs.append(index)
            selectedAssets[index] = asset
        }
    }
    
    func contains(_ current: IndexPath) -> Int {
        for (index, value) in selectedIndexs.enumerated() {
            if current == value {
                return index
            }
        }
        return -1
    }
}

extension CustomImagerPickerManager: PhotoManagerDelegate {
    func photoManagerDelCompletion(_ result: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.clear()
        }
    }
}
