//
//  Localizable-Extension.swift
//  
//
//  Created by yanghai on 2019/12/25.
//  Copyright © 2020 fwan. All rights reserved.
//  可以写个 comment,commit必须按照格式,否则无法解析 key@commit

import UIKit

@IBDesignable
extension UILabel {

    @IBInspectable
    var localizableKey: String? {
        get { return text }
        set {
            guard let newValue = newValue, !newValue.isEmpty else { return }
            text = NSLocalizedString(newValue, comment: "")

        }

    }
}

@IBDesignable
extension UIButton {

    @IBInspectable
    var localizableKey: String? {
        get { return currentTitle }
        set {
            guard let newValue = newValue, !newValue.isEmpty   else { return }
            setTitleForAllStates(NSLocalizedString(newValue, comment: ""))
        }

    }
}

@IBDesignable
extension UITextField {

    @IBInspectable
    var localizableKey: String? {
        get { return placeholder }
        set {
            guard let newValue = newValue, !newValue.isEmpty   else { return }
            placeholder = NSLocalizedString(newValue, comment: "")
        }

    }
}
