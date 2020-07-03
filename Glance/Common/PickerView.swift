//
//  PickerView.swift
//  
//
//  Created by yanghai on 11/18/19.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

class PickerView: UIPickerView {

    init () {
        super.init(frame: CGRect())
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
    }
}
