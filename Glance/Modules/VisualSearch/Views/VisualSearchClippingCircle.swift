//
//  ClippingCircle.swift
//  Image
//
//  Created by yanghai on 2020/7/29.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit


class VisualSearchClippingCircle: UIView {
    
    let corner : UIRectCorner
    var lineColor = UIColor.white
    var lineWidth : CGFloat = 10
    
    init(corner : UIRectCorner, frame : CGRect) {
        self.corner = corner
        super.init(frame: frame)
        layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()!
        
        // 4个角的 线的宽度
        let linewidthAngle : CGFloat = lineWidth // 经验参数：6和4
        
        // 画扫码矩形以及周边半透明黑色坐标参数
        let diffAngle : CGFloat = 0
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(linewidthAngle)
        context.setLineCap(.round)

        let wAngle : CGFloat = bounds.width
        let hAngle : CGFloat = bounds.height
        //
        let leftX = 0 - diffAngle
        let topY = 0 - diffAngle
        let rightX = bounds.width + diffAngle
        let bottomY = bounds.height + diffAngle
        
        switch corner {
        case .topLeft:
            // 左上角水平线
            context.move(to: CGPoint(x: leftX - linewidthAngle / 2, y: topY))
            context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))
            
            // 左上角垂直线
            context.move(to: CGPoint(x: leftX, y: topY - linewidthAngle / 2))
            context.addLine(to: CGPoint(x: leftX, y: topY + hAngle))
        case .bottomLeft:
            // 左下角水平线
            context.move(to: CGPoint(x: leftX - linewidthAngle / 2, y: bottomY))
            context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))
            
            // 左下角垂直线
            context.move(to: CGPoint(x: leftX, y: bottomY + linewidthAngle / 2))
            context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))
        case .topRight:
            // 右上角水平线
            context.move(to: CGPoint(x: rightX + linewidthAngle / 2, y: topY))
            context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))
            
            // 右上角垂直线
            context.move(to: CGPoint(x: rightX, y: topY - linewidthAngle / 2))
            context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))
        case .bottomRight:
            // 右下角水平线
            context.move(to: CGPoint(x: rightX + linewidthAngle / 2, y: bottomY))
            context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))
            
            // 右下角垂直线
            context.move(to: CGPoint(x: rightX, y: bottomY + linewidthAngle / 2))
            context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))
        default:
            break
        }
                
        context.strokePath()
        
    }
}
