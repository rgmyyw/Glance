//
//  FollowButton.swift
//  Glance
//
//  Created by yanghai on 2020/11/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

class FollowButton: Button {
    
    override func makeUI() {
        super.makeUI()
        
        titleLabel?.font = UIFont.titleFont(12)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        layer.borderColor = UIColor.primary().cgColor
        
        
        rx.observeWeakly(Bool.self, "selected", options: .new).filterNil()
            .subscribe(onNext: { [weak self](isSelected) in
                let background = isSelected ? UIColor.white : UIColor.primary()
                let titleColor = isSelected ? UIColor.primary() : UIColor.white
                let width = isSelected ? 1.0 : 0
                let title = isSelected ? "Following" : "+ Follow"
                self?.setTitleColor(titleColor, for: .normal)
                self?.backgroundColor = background
                self?.layer.borderWidth = width.cgFloat
                self?.setTitle(title, for: .normal)
                
            }).disposed(by: rx.disposeBag)

    }
}
