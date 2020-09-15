//
//  SearchFacets.swift
//  Glance
//
//  Created by yanghai on 2020/9/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct SearchFacet: Mappable {
    var count: Int = 0
    var facets: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        count   <- map["count"]
        facets   <- map["facets"]
    }
}
