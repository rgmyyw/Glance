//
//  Button.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

class Button: UIButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel?.font = UIFont.titleFont(16)
        titleLabel?.textColor = UIColor.text()
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    

    func makeUI() {
        
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        themeService.rx
            .bind({ UIImage(gradientColors: [UIColor(hex: 0xF56447)!,$0.primary])}, to: rx.backgroundImage(for: .normal))
            .bind({ UIImage(color: $0.separator)}, to: rx.backgroundImage(for: .disabled))
            .disposed(by: rx.disposeBag)
        layer.masksToBounds = true
        titleLabel?.lineBreakMode = .byWordWrapping

        updateUI()
    }

//
//    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
//        let insetRect = bounds.inset(by: textInsets)
//        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
//        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
//                                          left: -textInsets.left,
//                                          bottom: -textInsets.bottom,
//                                          right: -textInsets.right)
//        return textRect.inset(by: invertedInsets)
//    }



    func updateUI() {
        setNeedsDisplay()
    }
}
