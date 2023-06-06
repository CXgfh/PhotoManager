//
//  CustomImagerPickerViewController.swift
//  PhotoManager
//
//  Created by Vick on 2022/9/27.
//

import UIKit
import Util_V
import ContentSizeView
import Photos
import SnapKit

class CustomImagerPickerViewController: UIViewController {
    
    private lazy var manager = CustomImagerPickerManager(by: view, delegate: self)
    
    private let pattern: PhotoManager.ListPattern
        
    private var deletingAlbum: String?
    
    private var current: Int = -1
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(photo: "picker_return"), for: .normal)
        button.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(photo: "picker_text_color"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitle("筛选", for: .normal)
        button.addTarget(self, action: #selector(filterTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(photo: "picker_text_color"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitle("排序", for: .normal)
        button.addTarget(self, action: #selector(sortTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleView: PhotoTitileView = {
        let view = PhotoTitileView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(titleTap)))
        return view
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        let width = floor((min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 3)/3)
        layout.itemSize = CGSize(width: width, height: width)
        return layout
    }()
    
    private let identifier = "PhotoCollectionViewHeader"
    private lazy var collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collection.backgroundColor = UIColor(photo: "picker_theme_color")
        collection.delegate = self
        collection.dataSource = self
        collection.register(PhotoCollectionViewCell.self)
        collection.register(PhotoCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
        collection.alwaysBounceVertical = true
        return collection
    }()
    
    private lazy var catalogView: PhotoCatalogView = {
        let catalog = PhotoCatalogView()
        catalog.alpha = 0
        catalog.delegate = self
        return catalog
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        var style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .large
        } else {
            style = .whiteLarge
        }
        let activity = UIActivityIndicatorView(style: style)
        activity.color = .black
        activity.hidesWhenStopped = true
        return activity
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        activity.startAnimating()
        if !PhotoManager.sharde.isLoading {
            initData()
        }
        PhotoManager.sharde.delegate.add(self)
    }
    
    init(pattern: PhotoManager.ListPattern) {
        self.pattern = pattern
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomImagerPickerViewController {
    @objc private func backTap() {
        dismiss(animated: true)
    }
    
    @objc private func titleTap() {
        if manager.isPicking {
            return
        }
        if pattern == .default {
            titleView.changedIndicator()
            UIView.animate(withDuration: 0.17) {
                if self.titleView.isOpenMenu {
                    self.catalogView.alpha = 1
                } else {
                    self.catalogView.alpha = 0
                }
            }
        }
    }
    
    @objc private func sortTap() {
        if manager.isPicking {
            return
        }
        var options = [PhotoManager.Sort.size, .creationDate, .modificationDate]
        if PhotoManager.sharde.type == .video || PhotoManager.sharde.type == .audio {
            options.append(.duration)
        }
        
        let popover = NormalPopoverViewController<PhotoManager.Sort>(sort: options)
        popover.popoverPresentationController?.permittedArrowDirections = [.up]
        popover.popoverPresentationController?.sourceView = sortButton
        popover.popoverPresentationController?.sourceRect = CGRect(x: self.sortButton.frame.midX, y: self.sortButton.frame.maxY, width: 10, height: 10)
        popover.sort = { ascending, sort in
            self.activity.startAnimating()
            PhotoManager.sharde.ascending = ascending
            PhotoManager.sharde.sort = sort
            PhotoManager.sharde.sortAlbums()
        }
        self.present(popover, animated: true)
    }
    
    @objc private func filterTap() {
        if manager.isPicking {
            return
        }
        let popover = NormalPopoverViewController<PhotoManager.MediaType>(single: PhotoManager.MediaType.allCases)
        popover.popoverPresentationController?.permittedArrowDirections = [.up]
        popover.popoverPresentationController?.sourceView = filterButton
        popover.popoverPresentationController?.sourceRect = CGRect(x: self.filterButton.frame.midX, y: self.filterButton.frame.maxY, width: 10, height: 10)
        popover.single = { result in
            self.activity.startAnimating()
            PhotoManager.sharde.type = result
            PhotoManager.sharde.filterAlbums()
        }
        self.present(popover, animated: true)
    }
}

extension CustomImagerPickerViewController {
    private func setupUI() {
        view.backgroundColor = UIColor(photo: "picker_theme_color")
        navigationItem.leftBarButtonItem = .init(customView: backButton)
        navigationItem.titleView = titleView
        
        if pattern == .default {
            navigationItem.rightBarButtonItems = [.init(customView: sortButton), .init(customView: filterButton)]
        }
        
        navigationBar.changedTranslucent(isTranslucent: false)
        navigationBar.setTintColor(color: UIColor(photo: "picker_theme_color1") ?? .clear)
        navigationBar.setBackground(image: nil, color: UIColor(photo: "picker_theme_color") ?? .clear)
        titleView.title = "系统相册"
        
        self.view.addSubviews(collectionView, catalogView, activity)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        
        catalogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activity.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
    
    private func initData() {
        current = -1
        if pattern == .default {
            if let first = PhotoManager.sharde.defualtAlbums.first {
                current = 0
                titleView.title = first.title
            }
        } else {
            if let albums = PhotoManager.sharde.groupingAlbums {
                current = 0
                titleView.title = albums.title
            }
        }
        activity.stopAnimating()
    }
}

extension CustomImagerPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if pattern == .default {
            return 1
        } else {
            if let albums = PhotoManager.sharde.groupingAlbums {
                return albums.items.count
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if current == -1 {
            return 0
        } else {
            if pattern == .default {
                return PhotoManager.sharde.defualtAlbums[current].assets.count
            } else {
                return PhotoManager.sharde.groupingAlbums.items[section].assets.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if pattern == .default {
            return .zero
        } else {
            return CGSize(width: collectionView.width, height: 36)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath)
        if let header = headView as? PhotoCollectionReusableView,
           let albums = PhotoManager.sharde.groupingAlbums {
            header.title = albums.items[indexPath.section].title
        }
        return headView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withCellClass: PhotoCollectionViewCell.self, for: indexPath)
        if pattern == .default {
            cell.model = PhotoManager.sharde.defualtAlbums[current].assets[indexPath.row]
        } else {
            cell.model = PhotoManager.sharde.groupingAlbums.items[indexPath.section].assets[indexPath.row]
        }
        
        cell.chooseIndex = manager.contains(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var asset: PHAsset
        if pattern == .default {
            asset = PhotoManager.sharde.defualtAlbums[current].assets[indexPath.row].asset
        } else {
            asset = PhotoManager.sharde.groupingAlbums.items[indexPath.section].assets[indexPath.row].asset
        }
        
        switch PhotoManager.sharde.clickPattern {
        case .picker(let max):
            manager.picker(max, index: indexPath, asset: asset)
            collectionView.reloadItems(at: [indexPath])
        case .detail:
            showAssetDetail(asset)
        case .edit:
            editAsset(asset)
        case .waterMaker:
            waterMaker(asset)
        }
    }
    
    private func showAssetDetail(_ asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            let vc = ImageDetailViewController(asset: asset)
            navigationController?.pushViewController(vc, animated: true)
        case .video:
            let vc = VideoDetailViewController(asset: asset)
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
    private func editAsset(_ asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            let vc = EditImageViewController(asset: asset)
            vc.confirm = { new in
                self.dismiss(animated: true) {
                    PhotoManager.sharde.delegate.call {
                        $0.photoManagerEditResult?(image: new)
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        case .video:
            let vc = EditVideoViewController(phAsset: asset)
            vc.confirm = { new in
                self.dismiss(animated: true) {
                    PhotoManager.sharde.delegate.call {
                        $0.photoManagerEditResult?(video: new)
                    }
                }
            }
            navigationController?.pushViewController(vc, animated: true)
            break
        default:
            break
        }
    }
    
    private func waterMaker(_ asset: PHAsset) {
        //V_V水印
    }
}

extension CustomImagerPickerViewController: CustomImagerPickerManagerDelegate {
    func startPicker() {
        activity.startAnimating()
    }
    
    func endedCatch(_ result: [Any]) {
        activity.stopAnimating()
        var images = [UIImage]()
        var phAssets = [PHAsset]()
        var videos = [URL]()
        
        for elememt in result {
            if let image = elememt as? UIImage {
                images.append(image)
            } else if let video = elememt as? URL {
                videos.append(video)
            } else if let asset = elememt as? PHAsset {
                phAssets.append(asset)
            }
        }
        
        dismiss(animated: true) {
            PhotoManager.sharde.delegate.call {
                $0.photoManagerPickerResult?(assets: phAssets)
                $0.photoManagerPickerResult?(images: images)
                $0.photoManagerPickerResult?(videos: videos)
            }
        }
    }
    
    func startDel() {
        deletingAlbum = titleView.title
    }
}

extension CustomImagerPickerViewController: PhotoManagerDelegate {
    func photoManagerDidLoad() {
        if manager.isPicking {
            return
        }
        if deletingAlbum != nil {
            current = -1
            for (index, value) in PhotoManager.sharde.defualtAlbums.enumerated() {
                if value.title == deletingAlbum {
                    titleView.title = value.title
                    current = index
                }
            }
            if current == -1 {
                if let first = PhotoManager.sharde.defualtAlbums.first {
                    titleView.title = first.title
                    current = 0
                } else {
                    titleView.title = "系统相册"
                }
            }
            deletingAlbum = nil
        } else {
            initData()
        }
        activity.stopAnimating()
        collectionView.reloadData()
        catalogView.reloadData()
    }
}

extension CustomImagerPickerViewController: PhotoCatalogDelegate {
    func PhotoCatalogUnselect() {
        titleTap()
    }
    
    func PhotoCatalogSelect(at index: Int) {
        if current != index {
            current = index
            titleView.title = PhotoManager.sharde.defualtAlbums[index].title
            collectionView.reloadData()
            manager.clear()
        }
        titleTap()
    }
}
