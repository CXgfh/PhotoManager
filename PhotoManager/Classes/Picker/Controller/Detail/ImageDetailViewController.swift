//
//  ImageDetailViewController.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/30.
//

import UIKit
import Util_V
import Photos
import SnapKit


class ImageDetailViewController: UIViewController {
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_return")?.dyeing(by: .white), for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var photoView: PhotoDetailView = {
        let photo = PhotoDetailView(minZoomScale: 1, maxZoomScale: 3)
        photo.photoDelegate = self
        return photo
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(asset: PHAsset) {
        super.init(nibName: nil, bundle: nil)
        asset.getImage { image, info in
            self.photoView.currentImage = image
        }
    }
    
    init(image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        photoView.currentImage = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar.changedTranslucent(isTranslucent: false)
        navigationBar.setBackground(image: nil, color: UIColor(photo: "picker_theme_color") ?? .clear)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar.changedTranslucent(isTranslucent: true)
        navigationBar.setBackground(image: nil, color: UIColor.black.withAlphaComponent(0.7))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now()+coordinator.transitionDuration) {
            self.photoView.layoutImageView()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageDetailViewController {
    @objc private func backTap() {
        navigationController?.popViewController(animated: true)
    }
}

extension ImageDetailViewController {
    private func setupUI() {
        view.backgroundColor = .black
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        self.view.addSubview(photoView)
        photoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ImageDetailViewController: PhotoDetailDelegate {
    func photoDetailDidTap(_ photo: PhotoDetailView) {
        if let state = navigationController?.isNavigationBarHidden {
            navigationController?.setNavigationBarHidden(!state, animated: true)
        }
    }
    
    func photoDetailDidDoubleTap(_ photo: PhotoDetailView) {
        
    }
}
