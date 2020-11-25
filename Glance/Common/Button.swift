//
//  Button.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class Button: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel?.font = UIFont.titleFont(14)
        titleLabel?.textColor = UIColor.text()
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {

        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layer.masksToBounds = true
        titleLabel?.lineBreakMode = .byWordWrapping
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
