//
//  SearchThemeDetail.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct SearchThemeDetail: Mappable {
    
    var label = [SearchThemeDetailLabel]()
    var postCount: Int = 0
    var themeId: Int = 0
    var title: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        label   <- map["label"]
        postCount   <- map["postCount"]
        themeId   <- map["themeId"]
        title   <- map["title"]
    }
}

struct SearchThemeDetailLabel: Mappable {
    var name: String?
    var labelId: Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        name   <- map["name"]
        labelId   <- map["labelId"]
    }
}
