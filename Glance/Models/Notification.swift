//
//  Notification.swift
//  Glance
//
//  Created by yanghai on 2020/7/17.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper


struct Notice: Mappable {

    var read: Bool = false
    var time: Date? = Date()
    var image: String?
    var title: String?
    var notificationId: Int = 0
    var user: User?
    var type: NoticeType?
    var reaction : ReactionType?
    var theme : String?
    var description : String?
    var themeImages : [String] = []

    init?(map: Map) {}
    init() {
        
        var user = User()
        user.userId = "180"
        user.isFollow = true
        user.username = String.random(ofLength: Int.random(in: 5...10))
        user.userImage = "https://dss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1141259048,554497535&fm=26&gp=0.jpg"
        self.user = user
        
        read = Bool.random()
        time = Date.random(in: Date(milliseconds: 1602229073)...Date())
        type = NoticeType(rawValue: Int.random(in: 0...6))
        image = "https://dss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1141259048,554497535&fm=26&gp=0.jpg"
        reaction = ReactionType.haha
        theme = "#\(String.random(ofLength: Int.random(in: 5...10)))"
        description = String.random(ofLength: Int.random(in: 20...50))
        themeImages = ["https://dss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1141259048,554497535&fm=26&gp=0.jpg","https://dss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1141259048,554497535&fm=26&gp=0.jpg","https://dss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1141259048,554497535&fm=26&gp=0.jpg"]
    }

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
