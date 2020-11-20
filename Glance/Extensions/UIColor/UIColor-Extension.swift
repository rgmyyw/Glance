//
//  UIColor+.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

// MARK: Colors

extension UIColor {

    static func primary() -> UIColor {
        return themeService.type.associatedObject.primary
    }

    static func secondary() -> UIColor {
        return themeService.type.associatedObject.secondary
    }
    static func separator() -> UIColor {
        return themeService.type.associatedObject.separator
    }
    
    static func text() -> UIColor {
        return themeService.type.associatedObject.text
    }
    static func textGray() -> UIColor {
        return themeService.type.associatedObject.textGray
    }
    static func textSecondary() -> UIColor {
        return themeService.type.associatedObject.textSecondary
    }

    static func background() -> UIColor {
        return themeService.type.associatedObject.background
    }
    
    static func badgeBackground() -> UIColor {
        return UIColor(hex: 0xF2513F)!
    }
    
}


extension UIColor {

    var brightnessAdjustedColor: UIColor {
        var components = self.cgColor.components
        let alpha = components?.last
        components?.removeLast()
        let color = CGFloat(1-(components?.max())! >= 0.5 ? 1.0 : 0.0)
        return UIColor(red: color, green: color, blue: color, alpha: alpha!)
    }
}
