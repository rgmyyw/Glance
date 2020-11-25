//
//  TextField.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

@IBDesignable
class TextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    override var placeholder: String? {
        didSet {
            themeService.switch(themeService.type)
        }
    }

    func makeUI() {
        themeService.rx
            .bind({ $0.text }, to: rx.textColor)
            .bind({ $0.secondary }, to: rx.tintColor)
            .bind({ $0.textGray }, to: rx.placeholderColor)
            .bind({ $0.text }, to: rx.borderColor)
            .bind({ $0.keyboardAppearance }, to: rx.keyboardAppearance)
            .disposed(by: rx.disposeBag)

        layer.masksToBounds = true
        borderWidth = Configs.BaseDimensions.borderWidth
        cornerRadius = Configs.BaseDimensions.cornerRadius

        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.textFieldHeight)
        }
    }
}
