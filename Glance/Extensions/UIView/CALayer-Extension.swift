//
//  CALayer-Extension.swift
//  
//
//  Created by yanghai on 2020/1/16.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor?], start : CGPoint = CGPoint(x: 0, y: 0.5), end : CGPoint = CGPoint(x: 1, y: 0.5)) {
        self.init()
        self.frame = frame
        self.colors = colors.compactMap { $0?.cgColor }
        startPoint = start
        endPoint = end
    }

    func toImage() -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}

