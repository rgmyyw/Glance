//
//  GridLayar.swift
//  Image
//
//  Created by yanghai on 2020/7/29.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class VisualSearchGridLayar: CALayer {

    var clippingRect: CGRect = .zero
    var bgColor: UIColor = UIColor.clear
    var gridColor: UIColor = UIColor.red

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "clippingRect" { return true }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in ctx: CGContext) {

        var rect = bounds
        ctx.setFillColor(bgColor.cgColor)
        ctx.fill(rect)
        ctx.clear(clippingRect)

        ctx.setStrokeColor(gridColor.cgColor)
        ctx.setLineWidth(1)

        rect = clippingRect

        ctx.beginPath()
        var dw: CGFloat = 0

        (0..<4).forEach { (_) in
            ctx.move(to: CGPoint(x: rect.origin.x + dw, y: rect.origin.y))
            ctx.addLine(to: CGPoint(x: rect.origin.x + dw, y: rect.origin.y + rect.size.height))
            dw += clippingRect.size.width / 3
        }
        dw = 0
        (0..<4).forEach { (_) in
            ctx.move(to: CGPoint(x: rect.origin.x, y: rect.origin.y + dw))
            ctx.addLine(to: CGPoint(x: rect.origin.x + rect.size.width, y: rect.origin.y + dw))
            dw += clippingRect.size.height / 3
        }
        ctx.strokePath()
    }
}
