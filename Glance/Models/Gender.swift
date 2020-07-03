//
//  Gender.swift
//  
//
//  Created by yanghai on 2019/12/27.
//  Copyright © 2018 fwan. All rights reserved.
//

import UIKit

enum Gender : String {
    case male = "male"
    case female = "female"
    case secrecy = "privary"
    var title : String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .secrecy:
            return "Privary"
        }
    }
    
    static var rawValues : [String] {
        return [Gender.male.rawValue,Gender.female.rawValue,Gender.secrecy.rawValue]
    }
    
    static var titles : [String] {
        return [Gender.male.title,Gender.female.title,Gender.secrecy.title]
    }

}

