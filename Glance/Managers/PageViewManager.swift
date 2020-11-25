//
//  DNSPageViewManager.swift
//
//
//  Created by yanghai on 2020/1/13.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import DNSPageView
import RxCocoa
import RxSwift

extension PageStyle: ReactiveCompatible { }

extension Reactive where Base: PageTitleView {

    var titles: Binder<[String]> {
        return Binder(self.base) { titleView, titles in
            titleView.titles = titles
            titleView.setupUI()
        }
    }
}

extension Reactive where Base: PageContentView {

    var childViewControllers: Binder<[UIViewController]> {
        return Binder(self.base) { contentView, controllers in
            contentView.childViewControllers = controllers
            contentView.setupUI()
        }
    }
}

extension Reactive where Base: PageStyle {

    var bottomLineColor: Binder<UIColor> {
        return Binder(self.base) { style, color in
            style.bottomLineColor = color
        }
    }

    var titleColor: Binder<UIColor> {
        return Binder(self.base) { style, color in
            style.titleColor = color
        }
    }

    var titleSelectedColor: Binder<UIColor> {
        return Binder(self.base) { style, color in
            style.titleSelectedColor = color
        }
    }

}

let pageViewManager = PageViewManager.shared

class PageViewManager {

    static let shared = PageViewManager()
    private init() {}

    func globalStyle() -> PageStyle {
        let style = PageStyle()
        style.titleViewHeight = 44
        style.isTitleViewScrollEnabled = true
        style.isTitleScaleEnabled = false
        style.isShowBottomLine = false
        style.bottomLineHeight = 1.5
        style.bottomLineWidth = 0
        style.titleMargin = 28
        style.titleFont = UIFont.titleBoldFont(12)
        //style.titleSelectedFont =
        style.titleMaximumScaleFactor = 1.30

        themeService.rx
            .bind({ $0.primary }, to: style.rx.titleSelectedColor)
            .bind({ $0.textGray }, to: style.rx.titleColor)
            .bind({ $0.primary }, to: style.rx.bottomLineColor)
            .disposed(by: style.rx.disposeBag)
        return style

    }

}
