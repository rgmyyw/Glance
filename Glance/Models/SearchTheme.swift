//
//  SearchTheme.swift
//  Glance
//
//  Created by yanghai on 2020/9/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct SearchThemeItem: Mappable {
    var type: DefaultColltionCellType?
    var productId: String?
    var userId: Int = 0
    var image: String?
    var displayInfo: String?
    var postId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        type   <- map["type"]
        productId   <- map["productId"]
        userId   <- map["userId"]
        image   <- map["image"]
        displayInfo   <- map["displayInfo"]
        postId   <- map["postId"]
    }
}

struct SearchTheme: Mappable {
    var themeId: Int = 0
    var postList = [SearchThemeItem]()
    var title: String?
    var postCount: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        themeId   <- map["themeId"]
        postList   <- map["postList"]
        title   <- map["title"]
        postCount   <- map["postCount"]
    }
}
