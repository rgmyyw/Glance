//
//  Reusable-Extension.swift
//  
//
//  Created by yanghai on 2019/12/12.
//  Copyright © 2020 fwan. All rights reserved.
//

import Reusable

extension UIView : Reusable , NibLoadable  {
    
    public static func loadFromNib(height : CGFloat = 0, width : CGFloat = 0) -> Self {
        guard let loadView = nib.instantiate(withOwner: nil, options: nil).first as? UIView else {
          fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        
        if height > 0 , width  > 0 {
            loadView.snp.makeConstraints { (make) in
                if height > 0 {
                    make.height.equalTo(height)
                }
                if width > 0 {
                    make.width.equalTo(width)
                }
            }
        } else {
            loadView.frame = .zero
            logWarn("load \(self) frame is zero!")
        }
        
        guard let view = loadView as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

