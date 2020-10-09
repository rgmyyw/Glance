//
//  UsersType.swift
//  Glance
//
//  Created by yanghai on 2020/10/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit


enum UsersType {
    
    case followers
    case following
    case blocked
    
    var navigationTitle : String? {
        switch self {
        case .blocked:
            return "Blocked List"
        default:
            return nil
        }
    }
    
    var cellButtonNormalTitle : String {
        switch self {
        case .followers,.following:
            return "+ Follow"
        case .blocked:
            return "Block"
        }
        
    }
    var cellButtonSelectedTitle : String {
        switch self {
        case .followers,.following:
            return "Following"
        case .blocked:
            return "Blocked"
        }
    }
}

