//
//  UIView+Borders.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import WZLBadge

extension UIView {
    
    enum BorderSide {
        case left, top, right, bottom
    }
    
    func defaultBorderColor() -> UIColor {
        return UIColor.separator()
    }
    
    func defaultBorderDepth() -> CGFloat {
        return Configs.BaseDimensions.borderWidth
    }
    
    /// Add Border for side with default params
    ///
    /// - Parameter side: Border Side
    /// - Returns: Border view
    @discardableResult
    func addBorder(for side: BorderSide) -> UIView {
        return addBorder(for: side, color: defaultBorderColor(), depth: defaultBorderDepth())
    }
    
    /// Add Bottom Border with default params
    ///
    /// - Parameters:
    ///   - leftInset: left inset
    ///   - rightInset: right inset
    /// - Returns: Border view
    @discardableResult
    func addBottomBorder(leftInset: CGFloat = 10, rightInset: CGFloat = 0) -> UIView {
        let border = UIView()
        border.backgroundColor = defaultBorderColor()
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(leftInset)
            make.right.equalToSuperview().inset(rightInset)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.defaultBorderDepth())
        }
        return border
    }
    
    /// Add Top Border for side with color, depth, length and offsets
    ///
    /// - Parameters:
    ///   - side: Border Side
    ///   - color: Border Color
    ///   - depth: Border Depth
    ///   - length: Border Length
    ///   - inset: Border Inset
    ///   - cornersInset: Border Corners Inset
    /// - Returns: Border view
    @discardableResult
    func addBorder(for side: BorderSide, color: UIColor, depth: CGFloat, length: CGFloat = 0.0, inset: CGFloat = 0.0, cornersInset: CGFloat = 0.0) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        self.addSubview(border)
        border.snp.makeConstraints { (make) in
            switch side {
            case .left:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.equalToSuperview().inset(cornersInset)
                    make.bottom.equalToSuperview().inset(cornersInset)
                }
                make.left.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .top:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.equalToSuperview().inset(cornersInset)
                    make.right.equalToSuperview().inset(cornersInset)
                }
                make.top.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            case .right:
                if length != 0.0 {
                    make.height.equalTo(length)
                    make.centerY.equalToSuperview()
                } else {
                    make.top.equalToSuperview().inset(cornersInset)
                    make.bottom.equalToSuperview().inset(cornersInset)
                }
                make.right.equalToSuperview().inset(inset)
                make.width.equalTo(depth)
            case .bottom:
                if length != 0.0 {
                    make.width.equalTo(length)
                    make.centerX.equalToSuperview()
                } else {
                    make.left.equalToSuperview().inset(cornersInset)
                    make.right.equalToSuperview().inset(cornersInset)
                }
                make.bottom.equalToSuperview().inset(inset)
                make.height.equalTo(depth)
            }
        }
        return border
    }
    
    
    
    
}
extension UIView {
    
    /// 为View添加阴影
    func shadow(cornerRadius:CGFloat,shadowOpacity:CGFloat, shadowColor:UIColor, shadowOffset:CGSize,shadowRadius:CGFloat) {
        if cornerRadius != 0 {
            layer.cornerRadius = cornerRadius
            clipsToBounds = false
        }
        
        layer.shadowOpacity = Float(shadowOpacity)
        
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        
        //rasterize
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}

extension UIControl {
    
    private enum UIControlRuntimeKey {
        static var enlargeValidTouchAreaKey = "enlargeValidTouchAreaKey"
    }
    
    @IBInspectable
    var enlargeValidTouch : CGFloat {
        set {
            enlargeValidTouchArea = UIEdgeInsets(top: newValue, left: newValue, bottom: newValue, right: newValue)
        }
        get {
            return enlargeValidTouchArea.top
        }
    }
    
    var enlargeValidTouchArea : UIEdgeInsets {
        set {
            objc_setAssociatedObject(self, &UIControlRuntimeKey.enlargeValidTouchAreaKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &UIControlRuntimeKey.enlargeValidTouchAreaKey) as? NSValue else { return .zero}
            return  value.uiEdgeInsetsValue
        }
    }
    
    private var enlargeRect : CGRect {
        let inset = enlargeValidTouchArea
        return CGRect(x: bounds.minX - inset.left,
                      y: bounds.minY - inset.top,
                      width: bounds.width + inset.left + inset.right,
                      height: bounds.height + inset.top + inset.bottom)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isHidden || alpha == 0 {
            return false
        }
        let largeRect = enlargeRect
        if largeRect.equalTo(bounds) {
            return super.point(inside: point, with: event)
        }
        return largeRect.contains(point)
    }
}


extension UIView {
    
    func showBadge(value: Int, style : WBadgeStyle = .number, animationType: WBadgeAnimType = .none) {
        badgeCenterOffset = CGPoint(x: -3, y: 3)
        badgeBgColor = UIColor.badgeBackground()
        badgeTextColor = .white
        badgeFont = UIFont.titleFont(12)
        showBadge(with: style, value: value, animationType: animationType)
    }
}
