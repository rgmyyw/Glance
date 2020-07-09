//
//  BarButtonItem.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit

class BarButtonItem: UIBarButtonItem {

    typealias Action = (target : Any ,action : Selector)
    
    public var view : UIButton? {
        return customView as? UIButton
    }
    
    convenience init(title : String? = nil, imageName : String? = nil, image : UIImage? = nil, action : Action? = nil) {
        
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor.text(), for: .normal)
        button.titleLabel?.font = UIFont.titleFont(12)
        button.setTitleColor(UIColor.text(), for: .normal)
        if let title = title {
            button.setTitle(title, for: .normal)
        }
        if let imageName = imageName, let image = UIImage(named: imageName) {
            button.setImage(image, for: .normal)
        }
        
        if let image = image {
            button.setImage(image, for: .normal)
        }

        if let action = action {
            button.addTarget(action.target, action: action.action, for: .touchUpInside)
        }

        button.sizeToFit()
//        let contentView : UIView = UIView(frame: button.frame)
//         contentView.addSubview(button)
        self.init(customView: button)
      }
    
    
}

