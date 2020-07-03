//
//  StackView.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

class StackView: UIStackView {
    
    override var backgroundColor: UIColor? {
        set {
            let background = CALayer()
            background.backgroundColor = newValue?.cgColor
            layer.insertSublayer(background, at: 0)
        }
        get{
            return layer.sublayers?.first?.backgroundColor?.uiColor
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

    
    
    
    func updateUI() {
        setNeedsDisplay()
    }
}
