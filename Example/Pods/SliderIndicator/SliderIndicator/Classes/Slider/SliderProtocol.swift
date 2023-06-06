//
//  SliderProtocol.swift
//  SliderIndicator
//
//  Created by V on 2023/5/15.
//

import UIKit

public protocol SliderIndicatorDelegate: AnyObject {
    func sliderChanged(_ slider: SliderView, to newValue: Float)
    func sliderStartDragging(_ slider: SliderView)
    func sliderEndedDragging(_ slider: SliderView)
}

public protocol SliderView: UIView {
    var delegate: SliderIndicatorDelegate? { get set }
    var multiplied: Float { get set }
    var contentView: UIView { get }
    func showContent()
    func hideContent()
}

public protocol SliderIndicatorView: SliderView {
    func updateSlider()
    func addIndicator(_ indicator: UIView)
    var indicatorContentView: UIView { get }
    var extraContentView: UIView { get }
    
}

public protocol SliderLevelIndicatorView: SliderView {
    func setImage(_ image: UIImage?, _ state: SliderLevel)
}
