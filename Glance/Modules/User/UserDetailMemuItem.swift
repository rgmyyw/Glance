//
//  UserDetailMemuItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/25.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit


struct UserDetailMemuItem {
    var type : UserDetailMemuType
    var title : String {
        return type.title
    }
}

enum UserDetailMemuType {
    case report
    case block
    
    var title : String {
        switch self {
        case .report:
            return "Report user"
        case .block:
            return "Block user"
        }
    }
    var image : UIImage? {
        switch self {
        case .report:
            return R.image.icon_button_report()
        case .block:
            return R.image.icon_button_report()
        }
    }
}
