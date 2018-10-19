//
//  UIColorExtension.swift
//  PommeNews
//
//  Created by Jonathan Duss on 19.10.18.
//  Copyright © 2018 Swizapp. All rights reserved.
//

import UIKit

public extension UIColor {
    
    public func withBrightnessChange(_ brightnessChange: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue,
                       saturation: saturation,
                       brightness: brightness + brightnessChange,
                       alpha: alpha)
    }
}
