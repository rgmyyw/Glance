//
//  UIView-Rx.swift
//  
//
//  Created by yanghai on 2020/1/13.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WZLBadge


extension Reactive where Base: UITextField {
    
    var placeholder : Binder<String> {
        return Binder(self.base) { (textField, text) in
            textField.placeholder = text
        }
    }
}

extension Reactive where Base: UIView {
    
    var borderColor : Binder<UIColor?> {
        return Binder(self.base) { (view, color) in
            view.borderColor = color
        }
    }
}

extension Reactive where Base: UIView {
    
    var badgeValue : Binder<Int> {
        return Binder(self.base) { (view, value) in
            view.clipsToBounds = false
            view.badgeBgColor = UIColor.badgeBackground()
            view.badgeFont = UIFont.titleBoldFont(10)
            view.badgeTextColor = .white
            view.badgeCenterOffset = CGPoint(x: -5, y: 5)
            if value > 0 {
                view.showBadge(with: .number, value: value, animationType: .none)
            } else {
                view.clearBadge()
            }
        }
    }
}

extension Reactive where Base: UIScrollView {
    
    public var contentInset: Binder<UIEdgeInsets> {
        return Binder(self.base) { scrollView, contentInset in
            scrollView.contentInset = contentInset
        }
    }
    
    
}
