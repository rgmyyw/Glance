//
//  InsightsLike.swift
//  Glance
//
//  Created by yanghai on 2020/8/24.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct InsightsRelation: Mappable {
    var igHandler: String?
    var image: String?
    var isFollow: Bool = false
    var displayName: String?
    var userId: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        igHandler   <- map["igHandler"]
        image   <- map["image"]
        isFollow   <- map["isFollow"]
        displayName   <- map["displayName"]
        userId   <- map["userId"]

    }
}
