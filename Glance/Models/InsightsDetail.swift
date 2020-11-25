//
//  InsightsDetail.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct InsightsDetail: Mappable {

    var postId: Int = 0
    var interactionsCount: Int = 0
    var image: String?
    var title: String?
    var recommendId: Int = 0
    var created: Date?
    var reactionsCount: Int = 0
    var reachCount: Int = 0
    var recommendsCount: Int = 0
    var sharesCount: Int = 0
    var likesCount: Int = 0
    var saveCount: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        interactionsCount   <- map["interactionsCount"]
        image   <- map["image"]
        title   <- map["title"]
        recommendId   <- map["recommendId"]
        postId   <- map["postId"]
        created   <- (map["created"], ISO8601DateTransform())
        reachCount   <- map["reachCount"]
        interactionsCount   <- map["interactionsCount"]
        reactionsCount   <- map["reactionsCount"]
        recommendsCount   <- map["recommendsCount"]
        sharesCount   <- map["sharesCount"]
        likesCount   <- map["likesCount"]
        saveCount   <- map["saveCount"]

    }
}
