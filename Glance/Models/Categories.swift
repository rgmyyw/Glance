//
//  Categories.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct Categories: Mappable {
    var categoryId: Int = 0
    var level: Int = 0
    var name: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        categoryId   <- map["categoryId"]
        level   <- map["level"]
        name   <- map["name"]
    }
}
