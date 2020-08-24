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
    var borderWidth : Binder<CGFloat> {
        return Binder(self.base) { (view, width) in
            view.borderWidth = width
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

extension Reactive where Base: NavigationBar {
    
    var title: Binder<String> {
        return Binder(self.base) { bar, title in
            bar.title = title
            bar.layoutSubviews()
        }
    }
    
    
}

extension Reactive where Base: VisualSearchCropView {
    
    var image: Binder<UIImage?> {
        return Binder(self.base) { view, image in
            view.image = image
        }
    }

    var selectionBox: Binder<Box> {
        return Binder(self.base) { view, box in
            view.selectionBox(box: box)
        }
    }
        
    var updateBox: Binder<[(Bool,Box)]> {
        return Binder(self.base) { view, items in
            view.updateBox(actions: items)
        }
    }

    
}
