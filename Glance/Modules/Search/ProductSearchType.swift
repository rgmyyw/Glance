//
//  SearchType.swift
//  Glance
//
//  Created by yanghai on 2020/8/13.
//  Copyright © 2020 yanghai. All rights reserved.
//

import Foundation

enum ProductSearchType : Int {
    case saved = 0
    case posted
    case inApp
    var placeholder : String {
        switch self {
        case .saved:
            return "Search saved"
        case .posted:
            return "Search posted"
        case .inApp:
            return "Search in Glance app"
        }
    }
}
enum GlobalSearchType : Int {
    case all = -1
    case product = 1
    case post = 0
    case user = 4
}
