//
//  MinimumHitButton.swift
//  common
//
//  Created by Vick on 2022/3/17.
//

import UIKit

public class HotZoneButton: UIButton {
    
    public var hotZoneEdgeInsets: UIEdgeInsets = .zero
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hotZone = CGRect(x: bounds.origin.x - hotZoneEdgeInsets.left,
                             y: bounds.origin.y - hotZoneEdgeInsets.top,
                             width: bounds.width + hotZoneEdgeInsets.left + hotZoneEdgeInsets.right,
                             height: bounds.height + hotZoneEdgeInsets.top + hotZoneEdgeInsets.bottom)
        return hotZone.contains(point)
    }
}
