//
//  Switch.swift
//  
//
//  Created by yanghai on 7/23/18.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

class Switch: UISwitch {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        themeService.rx
            .bind({ $0.secondary }, to: [rx.tintColor, rx.onTintColor])
            .disposed(by: rx.disposeBag)
    }
}
