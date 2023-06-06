

import UIKit
import Photos
//import PhotosUI

//V_V支持下动图
@objc protocol PhotoDetailDelegate {
    func photoDetailDidTap(_ photo: PhotoDetailView)
    func photoDetailDidDoubleTap(_ photo: PhotoDetailView)
}

class PhotoDetailView: UIScrollView {
    
    var currentImage: UIImage? {
        didSet {
            imageView.image = currentImage
            layoutImageView()
        }
    }

    private lazy var imageView = UIImageView(frame: .zero)
//    lazy var animatedImageView = YYAnimatedImageView(frame: .zero)

    weak var photoDelegate: PhotoDetailDelegate?
    
    private let minZoomScale: CGFloat
    
    private let maxZoomScale: CGFloat

    var viewForTransition: UIView {
//        if animatedImageView.image != nil {
//            return animatedImageView
//        }
        return imageView
    }
    
    init(minZoomScale: CGFloat = 1.0, maxZoomScale: CGFloat = 3.0) {
        self.minZoomScale = minZoomScale
        self.maxZoomScale = maxZoomScale
        super.init(frame: .zero)
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        setupUI()
    }
    
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoDetailView {
    private func setupUI() {
        self.delegate = self
        self.backgroundColor = .clear
        let singlgeTap = UITapGestureRecognizer(target: self, action: #selector(singleClick(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleClick(_:)))
        doubleTap.numberOfTapsRequired = 2
        singlgeTap.require(toFail: doubleTap)
        self.addGestureRecognizer(singlgeTap)
        self.addGestureRecognizer(doubleTap)
        
        self.addSubview(imageView)
//        self.addSubview(animatedImageView)
    }
    
    func layoutImageView() {
        guard let currentImage = currentImage else { return }
        let imageRatio = currentImage.size.width / currentImage.size.height
        let photoRatio = bounds.width / bounds.height
        
        var imageFrame = CGRect.zero
        var scale: CGFloat = 0
        
        if imageRatio > photoRatio {
            imageFrame.size = CGSize(width: bounds.width,
                                     height: bounds.width / imageRatio)
            imageFrame.origin.x = 0
            imageFrame.origin.y = (bounds.height - imageFrame.height) / 2.0
            
            scale = bounds.height / imageFrame.height
        } else {
            imageFrame.size = CGSize(width: bounds.height * imageRatio,
                                     height: bounds.height)
            imageFrame.origin.x = (bounds.width - imageFrame.size.width) / 2.0
            imageFrame.origin.y = 0
            
            scale = bounds.width / imageFrame.width
        }
        self.maximumZoomScale = scale < maxZoomScale ? maxZoomScale : scale
        self.minimumZoomScale = scale < minZoomScale ? scale : minZoomScale
        
        imageView.frame = imageFrame
    }
}

extension PhotoDetailView {
    @objc fileprivate func singleClick(_ gesture: UITapGestureRecognizer) {
        self.photoDelegate?.photoDetailDidTap(self)
    }

    @objc fileprivate func doubleClick(_ gesture: UITapGestureRecognizer) {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let zoomRect = CGRect(origin: gesture.location(in: self), size: CGSize(width: 1, height: 1))
            zoom(to: zoomRect, animated: true)
        }
        photoDelegate?.photoDetailDidDoubleTap(self)
    }
}

extension PhotoDetailView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForTransition
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (bounds.width > contentSize.width) ? (bounds.width - contentSize.width)*0.5 : 0.0
        let offsetY = (bounds.height > contentSize.height) ? (bounds.height - contentSize.height) * 0.5 : 0.0
        let newCenter = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
        imageView.center = newCenter
//        animatedImageView.center = imageView.center
    }
}
