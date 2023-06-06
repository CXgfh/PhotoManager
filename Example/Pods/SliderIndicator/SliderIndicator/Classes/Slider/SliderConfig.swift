//
//  SliderConfig.swift
//  SliderIndicator
//
//  Created by Vick on 2022/10/9.
//

import UIKit

public enum SliderDirection {
    case vertical
    case horizontal
}

public struct SliderConfig {
    public static let shared = SliderConfig()
    
    public var direction: SliderDirection = .horizontal
    public var sliderSize: CGFloat = 4
    public var sliderColor: UIColor = .white
    public var progressColor: UIColor = .blue
    public var indicatorSize: CGFloat = 8
    public var indicatorCornerRadius: CGFloat = 4
    public var extraViewSize: CGFloat = 0
}

public enum SliderLevel: CaseIterable {
    case zero
    case one
    case two
    case three
    case max
    
    public init(progress: CGFloat) {
        switch progress {
        case 0:
            self = .zero
        case 0...0.33:
            self = .one
        case 0.33...0.66:
            self = .two
        case 0.66..<1:
            self = .three
        default:
            self = .max
        }
    }
}

public struct LevelSliderConfig {
    public static let shared = LevelSliderConfig()
    
    public var direction: SliderDirection = .vertical
    public var sliderWidth: CGFloat = 30
    public var sliderHeight: CGFloat = 100
    public var sliderCornerRadius: CGFloat = 10
    public var sliderColor: UIColor = .black.withAlphaComponent(0.7)
    public var progressColor: UIColor = .white
}


public struct VideoTailoringSliderConfig {
    public static let shared = VideoTailoringSliderConfig()
    
    public var contentHeight: CGFloat = 40
    public var contentColor: UIColor = .black.withAlphaComponent(0.7)
    public var lineColor: UIColor = .white
    public var cutColor: UIColor = .yellow
    public var cutWidth: CGFloat = 16
    public var indicatorWidth: CGFloat = 8
    public var minWidth: CGFloat = 50
    public var imagesCount: Int = 6
}


extension UIImage {
    convenience init?(tailoring named: String) {
        let bundle = Bundle(for: SliderDefaultIndicator.self)
        if let url = bundle.url(forResource: "SliderIndicator", withExtension: "bundle") {
            self.init(named: named, in: Bundle(url: url), compatibleWith: nil)
        } else {
            self.init(named: named, in: bundle, compatibleWith: nil)
        }
    }
}
