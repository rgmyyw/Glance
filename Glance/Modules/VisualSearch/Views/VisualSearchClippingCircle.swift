//
//  ClippingCircle.swift
//  Image
//
//  Created by yanghai on 2020/7/29.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchClippingCircle: UIView {
    
    var bgColor : UIColor = .white
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var rct = self.bounds;
        rct.origin.x = rct.size.width / 2 - rct.size.width / 6
        rct.origin.y = rct.size.height / 2 - rct.size.height / 6
        rct.size.width /= 3;
        rct.size.height /= 3;
        context?.setFillColor(bgColor.cgColor)
        context?.fillEllipse(in: rct)
    }
}
