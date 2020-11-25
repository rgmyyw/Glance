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
import PopMenu

extension Reactive where Base: UILabel {

    var textAlignment: Binder<NSTextAlignment> {
        return Binder(self.base) { (label, textAlignment) in
            label.textAlignment = textAlignment
        }
    }
}

extension Reactive where Base: UITextField {

    var placeholder: Binder<String> {
        return Binder(self.base) { (textField, text) in
            textField.placeholder = text
        }
    }
}

extension Reactive where Base: UIView {

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { (view, color) in
            view.borderColor = color
        }
    }
    var borderWidth: Binder<CGFloat> {
        return Binder(self.base) { (view, width) in
            view.borderWidth = width
        }
    }

}

extension Reactive where Base: UIView {

    var badgeValue: Binder<Int> {
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

    var selection: Binder<VisualSearchDotCellViewModel> {
        return Binder(self.base) { view, dot in
            view.selection(dot: dot)
        }
    }

    var dots: Binder<[VisualSearchDotCellViewModel]> {
        return Binder(self.base) { view, items in
            view.updateDots(dots: items)
        }
    }

}

extension DropDownView {

    func selection() -> Observable<Int> {
        let subject = PublishSubject<Int>()
        selectionAction = { index, item in
            subject.onNext(index)
        }
        return subject.asObservable()
    }

}

extension Reactive where Base: UIView {

    var becomeFirstResponder: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.becomeFirstResponder()
        }
    }

    var resignFirstResponder: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.resignFirstResponder()
        }
    }
}

extension Reactive where Base: UIView {

    var cornerRadius: Binder<CGFloat> {
        return Binder(self.base) { view, cornerRadius in
            view.layer.cornerRadius = cornerRadius
            view.layer.masksToBounds = true
        }
    }
}

extension UITextField: UITextFieldDelegate {

    private enum RuntimeKey {
        static var textFieldReturn = "textFieldReturn"
    }

    /// 监听内textFieldReturn 点击, 内部使用代理, 使用会覆盖
    func `return`() -> Observable<Void> {
        self.delegate = self

        if let subject = objc_getAssociatedObject(self, &RuntimeKey.textFieldReturn) as? PublishSubject<Void> {
            return subject.asObservable()
        }
        let subject = PublishSubject<()>()
        objc_setAssociatedObject(self, &RuntimeKey.textFieldReturn, subject, .OBJC_ASSOCIATION_RETAIN)
        return subject.asObservable()
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let subject = objc_getAssociatedObject(self, RuntimeKey.textFieldReturn) as? PublishSubject<()> else {
            return true
        }
        subject.onNext(())
        return true
    }
}
