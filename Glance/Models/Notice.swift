//
//  Notification.swift
//  Glance
//
//  Created by yanghai on 2020/7/17.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct Notice: Mappable, Equatable {
    var image: String?
    var images = [String]()
    var noticeId: Int = 0
    var noticeTime: Date?
    var read: Bool = false
    var themeId: Int = 0
    var title: String?
    var type: NoticeType?
    var user: User?
    var postId: Int = 0
    var recommendId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        image   <- map["image"]
        images   <- map["images"]
        noticeId   <- map["noticeId"]
        noticeTime   <- (map["noticeTime"], DateTransform())
        read   <- map["read"]
        themeId   <- map["themeId"]
        title   <- map["title"]
        type   <- map["type"]
        user   <- map["user"]
        postId <- map["postId"]
        recommendId <- map["recommendId"]
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.noticeId == rhs.noticeId
    }
}
