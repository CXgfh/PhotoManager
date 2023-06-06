//
//  ContentSizeOfCollectionView.swift
//  ContentSizeView
//
//  Created by Vick on 2022/9/19.
//

import UIKit

public class ContentSizeOfCollectionView: UICollectionView {
    
    public private(set) var maximumDisplayHeight: CGFloat?
    public private(set) var maximumDisplayWidth: CGFloat?
    
    public override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    public override var contentSize: CGSize {
        didSet {
            if translatesAutoresizingMaskIntoConstraints {
                sizeToFit()
            } else {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        newSize()
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        newSize()
    }
    
    public init(frame: CGRect, collectionViewLayout layout: ContentSizeOfFlowLayout, maximumDisplayHeight: CGFloat? = nil, maximumDisplayWidth: CGFloat? = nil) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.maximumDisplayWidth = maximumDisplayWidth
        self.maximumDisplayHeight = maximumDisplayHeight
    }
    
    private func newSize() -> CGSize {
        if let layout = collectionViewLayout as? ContentSizeOfFlowLayout {
            if layout.scrollDirection == .vertical {
                if let height = maximumDisplayHeight {
                    return CGSize(width: contentSize.width, height: height)
                }
            } else {
                if let width = maximumDisplayWidth {
                    return CGSize(width: width, height: contentSize.height)
                }
            }
        }
        return contentSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
