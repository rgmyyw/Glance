//
//  Notification.swift
//  Glance
//
//  Created by yanghai on 2020/7/17.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct Notification: Mappable {
    var read: Bool = false
    var time: Date?
    var image: String?
    var title: String?
    var notificationId: Int = 0
    var user: User?
    var type: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        read   <- map["read"]
        time   <- (map["time"],ISO8601DateTransform())
        image   <- map["image"]
        title   <- map["title"]
        notificationId   <- map["notificationId"]
        user   <- map["user"]
        type   <- map["type"]
    }
}
