//
//  ImageTailoringSliderIndicator.swift
//  SliderIndicator
//
//  Created by V on 2023/5/10.
//

import UIKit
import SnapKit

public class ImageTailoringSliderIndicator: UIView {
    
    public var image: UIImage? {
        didSet {
            imageView.image = image
            updateFrame()
        }
    }
    
    private var tailoringEdge: CGFloat = 10
    
    private var minSize: CGFloat = 100

    private var topLayout: NSLayoutConstraint?
    private lazy var topTaoloringLine: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.tag = 1
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panTap)))
        return object
    }()
    
    private var bottomLayout: NSLayoutConstraint?
    private lazy var bottomTaoloringLine: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.tag = 2
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panTap)))
        return object
    }()
    
    private var leftLayout: NSLayoutConstraint?
    private lazy var leftTaoloringLine: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.tag = 3
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panTap)))
        return object
    }()
    
    private var rightLayout: NSLayoutConstraint?
    private lazy var rightTaoloringLine: UIView = {
        let object = UIView()
        object.backgroundColor = .white
        object.tag = 4
        object.isUserInteractionEnabled = true
        object.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panTap)))
        return object
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.isPagingEnabled = false
        scroll.zoomScale = 1
        scroll.maximumZoomScale = 2
        scroll.minimumZoomScale = 0.001
        scroll.delegate = self
        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        }
        scroll.addSubviews(imageView)
        return scroll
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageTailoringSliderIndicator {
    @objc private func panTap(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            let point = sender.translation(in: self)
            sender.setTranslation(.zero, in: self)
            let tag = sender.view?.tag
            switch tag {
            case 1:
                if let top = topLayout?.constant, let bottom = bottomLayout?.constant {
                    if top + point.y < 0 {
                        topLayout?.constant = 0
                    } else if top - bottom + minSize + point.y > scrollView.height {
                        topLayout?.constant = scrollView.height - minSize + bottom
                    } else {
                        topLayout?.constant = top + point.y
                    }
                }
            case 2:
                if let top = topLayout?.constant, let bottom = bottomLayout?.constant {
                    if bottom + point.y > 0 {
                        bottomLayout?.constant = 0
                    } else if top - bottom + minSize - point.y > scrollView.height {
                        bottomLayout?.constant = top + minSize - scrollView.height
                    } else {
                        bottomLayout?.constant = bottom + point.y
                    }
                }
            case 3:
                if let left = leftLayout?.constant, let right = rightLayout?.constant {
                    if left + point.x < 0 {
                        leftLayout?.constant = 0
                    } else if left - right + minSize + point.x > scrollView.width {
                        leftLayout?.constant = scrollView.width - minSize + right
                    } else {
                        leftLayout?.constant = left + point.x
                    }
                }
            case 4:
                if let left = leftLayout?.constant, let right = rightLayout?.constant {
                    if right + point.x > 0 {
                        rightLayout?.constant = 0
                    } else if left - right + minSize - point.x > scrollView.width {
                        rightLayout?.constant = left + minSize - scrollView.width
                    } else {
                        rightLayout?.constant = right + point.x
                    }
                }
            default:
                break
            }
        default:
            break
        }
    }
    
    public func tailoringRect() -> CGRect {
        if let top = topLayout?.constant, let bottom = bottomLayout?.constant, let left = leftLayout?.constant, let right = rightLayout?.constant {
            let image = imageView.image
            let scale = scrollView.zoomScale/(image?.scale ?? 1)
            let rect = CGRect(x: left/scale, y: top/scale, width: (scrollView.width-left+right)/scale, height: (scrollView.height-top+bottom)/scale)
            return rect
        }
        return self.frame
    }
}

extension ImageTailoringSliderIndicator {
    private func setupUI() {
        self.addSubview(scrollView)
        
        self.addSubviews(topTaoloringLine, bottomTaoloringLine, leftTaoloringLine, rightTaoloringLine)
        
        topLayout = NSLayoutConstraint(item: topTaoloringLine, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        topLayout?.isActive = true
        topTaoloringLine.snp.makeConstraints { make in
            make.left.equalTo(leftTaoloringLine.snp.left)
            make.right.equalTo(rightTaoloringLine.snp.right)
            make.height.equalTo(tailoringEdge)
        }
        
        bottomLayout = NSLayoutConstraint(item: bottomTaoloringLine, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1, constant: 0)
        bottomLayout?.isActive = true
        bottomTaoloringLine.snp.makeConstraints { make in
            make.left.equalTo(leftTaoloringLine.snp.left)
            make.right.equalTo(rightTaoloringLine.snp.right)
            make.height.equalTo(tailoringEdge)
        }
        
        leftLayout = NSLayoutConstraint(item: leftTaoloringLine, attribute: .right, relatedBy: .equal, toItem: scrollView, attribute: .left, multiplier: 1, constant: 0)
        leftLayout?.isActive = true
        leftTaoloringLine.snp.makeConstraints { make in
            make.top.equalTo(topTaoloringLine.snp.top)
            make.bottom.equalTo(bottomTaoloringLine.snp.bottom)
            make.width.equalTo(tailoringEdge)
        }
        
        rightLayout = NSLayoutConstraint(item: rightTaoloringLine, attribute: .left, relatedBy: .equal, toItem: scrollView, attribute: .right, multiplier: 1, constant: 0)
        rightLayout?.isActive = true
        rightTaoloringLine.snp.makeConstraints { make in
            make.top.equalTo(topTaoloringLine.snp.top)
            make.bottom.equalTo(bottomTaoloringLine.snp.bottom)
            make.width.equalTo(tailoringEdge)
        }
        
    }
    
    public func updateFrame() {
        guard let iSize = imageView.image?.size else { return }
        layoutIfNeeded()
        self.imageView.frame = CGRect(origin: .zero, size: iSize)
        self.scrollView.contentSize = iSize
        
        let maxWidth = width - 2*tailoringEdge
        let maxHeight = height - 2*tailoringEdge
        
        if iSize.width/maxWidth > iSize.height/maxHeight {
            self.scrollView.minimumZoomScale = maxWidth/iSize.width
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            let newHeight = maxWidth/iSize.width*iSize.height
            self.scrollView.frame = CGRect(x: tailoringEdge, y: (maxHeight-newHeight)/2, width: maxWidth, height: newHeight)
        } else {
            self.scrollView.minimumZoomScale = maxHeight/iSize.height
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
            let newWidth = maxHeight/iSize.height*iSize.width
            self.scrollView.frame = CGRect(x: (maxWidth-newWidth)/2, y: tailoringEdge, width: newWidth, height: maxHeight)
        }
    }
}


extension ImageTailoringSliderIndicator: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
