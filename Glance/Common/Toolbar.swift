//
//  Toolbar.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class Toolbar: UIToolbar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        isTranslucent = false
        themeService.rx
            .bind({ $0.barStyle }, to: rx.barStyle)
            .bind({ $0.global }, to: rx.barTintColor)
            .bind({ $0.secondary }, to: rx.tintColor)
            .disposed(by: rx.disposeBag)

        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.tableRowHeight)
        }
    }
}
