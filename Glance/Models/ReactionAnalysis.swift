//
//  ReactionAnalysis.swift
//  Glance
//
//  Created by yanghai on 2020/8/26.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct ReactionAnalysis: Mappable {
    var heart: Int = 0
    var haha: Int = 0
    var wow: Int = 0
    var sad : Int = 0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        heart   <- map["heart"]
        haha   <- map["haha"]
        wow   <- map["wow"]
        sad   <- map["sad"]
    }
}
