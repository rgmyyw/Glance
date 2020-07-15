//
//  Insight.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct Insight: Mappable {
    var recommendId : Int = 0
    var postId: Int = 0
    var interactionsCount: Int = 0
    var image: String?
    var reachCount: Int = 0
    var title: String?
    var created: Date?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        created   <- (map["created"] ,ISO8601DateTransform())
        postId   <- map["postId"]
        interactionsCount   <- map["interactionsCount"]
        image   <- map["image"]
        reachCount   <- map["reachCount"]
        title   <- map["title"]
        recommendId   <- map["recommendId"]
    }
}
