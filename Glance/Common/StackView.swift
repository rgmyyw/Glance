//
//  StackView.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class StackView: UIStackView {

    override var backgroundColor: UIColor? {
        get { return layer.sublayers?.first?.backgroundColor?.uiColor }
        set {
            let background = CALayer()
            background.backgroundColor = newValue?.cgColor
            layer.insertSublayer(background, at: 0)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func makeUI() {
        spacing = inset
        axis = .vertical
        // self.distribution = .fill

        updateUI()
    }

    override func addArrangedSubview(_ view: UIView) {
        view.removeFromSuperview()
        super.addArrangedSubview(view)
    }

    override func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        view.removeFromSuperview()
        super.insertArrangedSubview(view, at: stackIndex)
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
