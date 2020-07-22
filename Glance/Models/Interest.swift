//
//  Interest.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct Interest: Mappable {
    var image: String?
    var interestId: Int = 0
    var name: String?
    var level: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        image   <- map["image"]
        interestId   <- map["interestId"]
        name   <- map["name"]
        level   <- map["level"]
    }
}
