//
//  SearchThemeClassify.swift
//  Glance
//
//  Created by yanghai on 2020/9/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct SearchThemeClassify: Mappable {
    
    var classifyName: String?
    var classifyId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        classifyName   <- map["classifyName"]
        classifyId   <- map["classifyId"]
    }
}

