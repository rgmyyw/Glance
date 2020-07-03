//
//  Message.swift
//  
//
//  Created by 杨海 on 2020/4/4.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import Toast_Swift

struct Message : CustomStringConvertible {
    
    var title : String?
    var subTitle : String = ""
    var style : ToastStyle = ToastStyle()

    init(_ message : String) {
        self.subTitle = message
    }
    
    var description: String {
        return "Message: \(title ?? "" + subTitle)"
    }
}

