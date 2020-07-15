//
//  Reaction.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

enum ReactionType : Int {
    case heart = 0
    case haha = 1
    case wow = 2
}

struct Reaction: Mappable {
    var displayName: String?
    var reactionType: ReactionType?
    var userId: String?
    var isFollow: Bool = false
    var igHandler: String?
    var image: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        displayName   <- map["displayName"]
        reactionType   <- map["reactionType"]
        userId   <- map["userId"]
        isFollow   <- map["isFollow"]
        igHandler   <- map["igHandler"]
        image   <- map["image"]
    }
}
