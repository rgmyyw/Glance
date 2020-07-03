//
//  Gradient-Extension.swift
//  
//
//  Created by yanghai on 2020/1/16.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

extension UIView {
    
    func addGradient(colors: [UIColor?], start : CGPoint = CGPoint(x: 0, y: 0.5), end : CGPoint = CGPoint(x: 1, y: 0.5)) {
        setNeedsLayout()
        layoutIfNeeded()
        let gradientLayer = CAGradientLayer(frame: bounds, colors: colors, start: start, end: end)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addThemeGradient() {
        addGradient(colors: [UIColor(hex:0xF56447),UIColor.primary()])
    }
}


