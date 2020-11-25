//
//  Badge.swift
//  Glance
//
//  Created by yanghai on 2020/11/19.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct Badge: Mappable {

    var notice: Int = 0
    var message: Int = 0
    var app: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        notice   <- map["noticeCount"]
        message   <- map["messageCount"]
        app   <- map["total"]
    }
}

struct NotificationPayloadItem: Mappable {

    var rawType: Int?
    var postId: Int = 0
    var userId: String?
    var themeId: Int = 0
    var recommendedId: Int = 0

    var type: NoticeType? {
        return NoticeType(rawValue: rawType ?? 0)
    }

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        rawType   <- (map["type"], StringToIntTransform())
        postId   <- (map["postId"], StringToIntTransform())
        userId   <- map["userId"]
        themeId <- (map["themeId"], StringToIntTransform())
        recommendedId <- (map["recommendedId"], StringToIntTransform())
    }
}
