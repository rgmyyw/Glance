//
//  VisualSearchDotButton.swift
//  Glance
//
//  Created by yanghai on 2020/10/19.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VisualSearchDotButton: UIButton {

    public let dot: VisualSearchDotCellViewModel

    init(center: CGPoint, dot: VisualSearchDotCellViewModel, size: CGSize = CGSize(width: 21, height: 21)) {
        self.dot = dot
        super.init(frame: CGRect(origin: .zero, size: size))
        self.adjustsImageWhenDisabled = false
        self.adjustsImageWhenHighlighted = false
        self.layer.cornerRadius = frame.height / 2
        self.layer.masksToBounds = true
        self.alpha = 0
        self.center = center

        dot.state.subscribe(onNext: { [weak self](state) in
            //self?.isSelected = (state == .selected).boolValue
            let image = (state == .selected).boolValue ? UIImage(color: UIColor.primary()) : UIImage(color: .white)
            self?.setImage(image, for: .normal)
            self?.alpha = (state != .hidden).int.cgFloat
        }).disposed(by: rx.disposeBag)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
