//
//  SearchRecommendHotCategory.swift
//  Glance
//
//  Created by yanghai on 2020/9/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct SearchRecommendHotCategory: Mappable {

    var title: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        title   <- map["title"]
    }
}
