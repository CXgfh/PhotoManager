//
//  ImageTailoringViewController.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/30.
//

import UIKit
import Photos
import Util_V
import SnapKit
import SliderIndicator

class EditImageViewController: UIViewController {
    
    var confirm: ((_ image: UIImage?)->Void)?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_return"), for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(photo: "picker_text_color"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitle("确认", for: .normal)
        button.addTarget(self, action: #selector(confirmTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var tailoringView: ImageTailoringSliderIndicator = {
        let tailoring = ImageTailoringSliderIndicator()
        return tailoring
    }()
    
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now()+coordinator.transitionDuration) {
            self.tailoringView.updateFrame()
        }
    }
    
    init(asset: PHAsset) {
        super.init(nibName: nil, bundle: nil)
        asset.getImage { image, info in
            self.image = image
            self.tailoringView.image = image
        }
    }
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
        self.tailoringView.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditImageViewController {
    @objc private func backTap() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func confirmTap() {
        let rect = self.tailoringView.tailoringRect()
        let new = image?.tailor(by: rect)
        self.confirm?(new)
    }
}

extension EditImageViewController {
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        title = "编辑"
        navigationItem.rightBarButtonItem = .init(customView: confirmButton)
        
        
        self.view.addSubview(tailoringView)
        tailoringView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
