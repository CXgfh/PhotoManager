//
//  ContentSizeOfFlowLayout.swift
//  ContentSizeView
//
//  Created by V on 2023/2/16.
//

import UIKit

/*
 先有布局宽度(或高度);
 再有contentSize的高度(或宽度);
 最后撑开CollectionView大小;
 仅支持header、cell、footer， V_V 未计算decorationView计算布局
 */
open class ContentSizeOfFlowLayout: UICollectionViewLayout {
    
    private enum CellFrameCalculateType {
        case nowLine
        case nextLine
    }
    
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    public var sectionInset: UIEdgeInsets = .zero
    
    public var itemInset: UIEdgeInsets = .zero
    
    public var itemSize: CGSize = .zero
    
    private var layoutDisplayWidth: CGFloat = 0
    
    private var layoutDisplayHeight: CGFloat = 0
    
    private var basedLayout: CGFloat = 0
    
    private var delegate: UICollectionViewDelegateFlowLayout?
    
    private var lastMaximumWidth: CGFloat = 0
    private var currentMaximumWidth: CGFloat = 0
    
    private var lastMaximumHeight: CGFloat = 0
    private var currentMaximumHeight: CGFloat = 0
    
    private var layoutArr: [UICollectionViewLayoutAttributes] = []
    
    public override func prepare() {
        super.prepare()
        reset()
        guard let collectionView = collectionView as? ContentSizeOfCollectionView else { return
        }
        for section in 0..<collectionView.numberOfSections {
            if let layout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section)),
                layout.frame != .zero {
                layoutArr.append(layout)
            }
            for row in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if let layout = layoutAttributesForItem(at: indexPath) {
                    layoutArr.append(layout)
                }
            }
            if let layout = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: IndexPath(row: 0, section: section)),
                layout.frame != .zero {
                layoutArr.append(layout)
            }
        }
    }
    
    private func reset() {
        lastMaximumWidth = 0
        currentMaximumWidth = 0
        lastMaximumHeight = 0
        currentMaximumHeight = 0
        layoutArr = []
        
        delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout
        
        guard let collectionView = collectionView as? ContentSizeOfCollectionView else {
            layoutDisplayWidth = 0
            layoutDisplayHeight = 0
            basedLayout = 0
            return
        }
        
        if let max = collectionView.maximumDisplayWidth {
            layoutDisplayWidth = max
        } else if collectionView.bounds.width > 0 {
            layoutDisplayWidth = collectionView.bounds.width
        } else {
            layoutDisplayWidth = collectionView.superview?.bounds.width ?? 0
        }
        
        if let max = collectionView.maximumDisplayHeight {
            layoutDisplayHeight = max
        } else if collectionView.bounds.height > 0 {
            layoutDisplayHeight = collectionView.bounds.height
        } else {
            layoutDisplayHeight = collectionView.superview?.bounds.height ?? 0
        }
        
        basedLayout = scrollDirection == .vertical ? layoutDisplayWidth : layoutDisplayHeight
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard collectionView != nil else {
            return nil
        }
        let layout = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        return updateLayoutAttributesForItem(layout, at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard collectionView != nil else {
            return nil
        }
        let layout = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        return updateLayoutAttributesForSupplementaryView(layout, ofKind: elementKind, at: indexPath)
    }
    
    public override var collectionViewContentSize: CGSize {
        if let last = layoutArr.last, last.representedElementCategory == .cell {
            if scrollDirection == .vertical {
                currentMaximumHeight += itemInset.bottom
            } else {
                currentMaximumWidth += itemInset.right
            }
            return CGSize(width: currentMaximumHeight, height: currentMaximumWidth)
        }
        return CGSize(width: currentMaximumWidth, height: currentMaximumHeight)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //V_V
//        var layoutAttributes = [UICollectionViewLayoutAttributes]()
//        guard self.itemSpacing > 0, !rect.isEmpty else {
//            return layoutAttributes
//        }
//        let rect = rect.intersection(CGRect(origin: .zero, size: self.contentSize))
//        guard !rect.isEmpty else {
//            return layoutAttributes
//        }
//        // Calculate start position and index of certain rects
//        let numberOfItemsBefore = self.scrollDirection == .horizontal ? max(Int((rect.minX-self.leadingSpacing)/self.itemSpacing),0) : max(Int((rect.minY-self.leadingSpacing)/self.itemSpacing),0)
//        let startPosition = self.leadingSpacing + CGFloat(numberOfItemsBefore)*self.itemSpacing
//        let startIndex = numberOfItemsBefore
//        // Create layout attributes
//        var itemIndex = startIndex
//
//        var origin = startPosition
//        let maxPosition = self.scrollDirection == .horizontal ? min(rect.maxX,self.contentSize.width-self.actualItemSize.width-self.leadingSpacing) : min(rect.maxY,self.contentSize.height-self.actualItemSize.height-self.leadingSpacing)
//        // https://stackoverflow.com/a/10335601/2398107
//        while origin-maxPosition <= max(CGFloat(100.0) * .ulpOfOne * abs(origin+maxPosition), .leastNonzeroMagnitude) {
//            let indexPath = IndexPath(item: itemIndex%self.numberOfItems, section: itemIndex/self.numberOfItems)
//            let attributes = self.layoutAttributesForItem(at: indexPath) as! FSPagerViewLayoutAttributes
//            self.applyTransform(to: attributes, with: self.pagerView?.transformer)
//            layoutAttributes.append(attributes)
//            itemIndex += 1
//            origin += self.itemSpacing
//        }
//        return layoutAttributes
        return layoutArr
    }
    
    public override init() {
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ContentSizeOfFlowLayout {
    private func updateLayoutAttributesForItem(_ layout: UICollectionViewLayoutAttributes, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView,
              basedLayout > 0 else {
            return layout
        }
        
        var _itemSize: CGSize
        if let delegateSize = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
            _itemSize = delegateSize
        } else {
            _itemSize = self.itemSize
        }
        
        let _sectionInsets: UIEdgeInsets
        if let delegateSectionInsets = delegate?.collectionView?(collectionView, layout: self, insetForSectionAt: indexPath.section) {
            _sectionInsets = delegateSectionInsets
        } else {
            _sectionInsets = sectionInset
        }
        
        var type = CellFrameCalculateType.nowLine
        var x: CGFloat = 0 //vertical布局时使用
        var y: CGFloat = 0 //horizontal布局时使用
        
        if let last = layoutArr.last {
            switch last.representedElementCategory {
            case .cell:
                if scrollDirection == .vertical {
                    if last.frame.maxX + _itemSize.width + _sectionInsets.right + itemInset.right + itemInset.left > layoutDisplayWidth {
                        type = .nextLine
                        currentMaximumHeight += itemInset.bottom
                    } else {
                        x = last.frame.maxX
                    }
                } else {
                    if last.frame.maxY + _itemSize.height + _sectionInsets.bottom + itemInset.top + itemInset.bottom > layoutDisplayHeight {
                        type = .nextLine
                        currentMaximumWidth += itemInset.right
                    } else {
                        y = last.frame.maxY
                    }
                }
            case .supplementaryView:
                type = .nextLine
                if scrollDirection == .vertical {
                    currentMaximumHeight += _sectionInsets.top
                } else {
                    currentMaximumWidth += _sectionInsets.left
                }
            default:
                fatalError("暂时不支持当前类型视图的计算")
            }
        } else {
            type = .nextLine
        }
        
        if scrollDirection == .vertical {
            switch type {
            case .nowLine:
                layout.frame = CGRect(x: x + itemInset.right + itemInset.left,
                                      y: lastMaximumHeight + itemInset.top,
                                      width: _itemSize.width,
                                      height: _itemSize.height)
            case .nextLine:
                lastMaximumHeight = currentMaximumHeight
                layout.frame = CGRect(x: _sectionInsets.left + itemInset.left,
                                      y: lastMaximumHeight + itemInset.top,
                                      width: _itemSize.width,
                                      height: _itemSize.height)
            }
        } else {
            switch type {
            case .nowLine:
                layout.frame = CGRect(x: lastMaximumWidth+itemInset.left,
                                      y: y + itemInset.top + itemInset.bottom,
                                      width: _itemSize.width,
                                      height: _itemSize.height)
            case .nextLine:
                lastMaximumWidth = currentMaximumWidth
                layout.frame = CGRect(x: lastMaximumWidth + itemInset.left,
                                      y: _sectionInsets.top + itemInset.top,
                                      width: _itemSize.width,
                                      height: _itemSize.height)
            }
        }
        updateContentSize(layout)
        return layout
    }
    
    private func updateLayoutAttributesForSupplementaryView(_ layout: UICollectionViewLayoutAttributes, ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView,
              basedLayout > 0 else {
            return layout
        }
        
        if let last = layoutArr.last {
            switch last.representedElementCategory {
            case .cell:
                if scrollDirection == .vertical {
                    currentMaximumHeight = currentMaximumHeight + sectionInset.bottom + itemInset.bottom
                    lastMaximumHeight = currentMaximumHeight
                } else {
                    currentMaximumWidth = currentMaximumWidth + sectionInset.right + itemInset.right
                    lastMaximumWidth = currentMaximumWidth
                }
            case .supplementaryView:
                if scrollDirection == .vertical {
                    currentMaximumHeight = currentMaximumHeight + sectionInset.bottom + sectionInset.top
                    lastMaximumHeight = currentMaximumHeight
                } else {
                    currentMaximumWidth = currentMaximumWidth + sectionInset.right + sectionInset.left
                    lastMaximumWidth = currentMaximumWidth
                }
            default:
                fatalError("暂时不支持当前类型视图的计算")
            }
        }
        
        
        var size: CGSize = .zero
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section) ?? .zero
        case UICollectionView.elementKindSectionFooter:
            size = delegate?.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: indexPath.section) ?? .zero
        default:
            break
        }
        
        let x = scrollDirection == .vertical ? (collectionView.bounds.width - size.width)/2 : currentMaximumWidth
        let y = scrollDirection == .vertical ? currentMaximumHeight : (collectionView.bounds.height - size.height)/2
        layout.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        updateContentSize(layout)
        return layout
    }
    
    private func updateContentSize(_ layout: UICollectionViewLayoutAttributes) {
        currentMaximumWidth = max(layout.frame.maxX, currentMaximumWidth)
        currentMaximumHeight = max(layout.frame.maxY, currentMaximumHeight)
    }
}
