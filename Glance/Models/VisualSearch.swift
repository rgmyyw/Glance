//
//  VisualSearch.swift
//  Glance
//
//  Created by yanghai on 2020/7/31.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct VisualSearchPageMapable : Mappable {
    
    var total: Int = 0
    var pageNum: Int = 0
    var list = [Home]()
    var hasNext: Bool = true
    var pageSize: Int = 0
    var hasPrevious: Bool = false
    var imId:  String?

    init?(map: Map) {}
    init(hasNext : Bool = true) {
        self.hasNext = hasNext
    }

    mutating func mapping(map: Map) {
        total   <- map["total"]
        pageNum   <- map["pageNum"]
        list   <- map["productList"]
        hasNext   <- map["hasNext"]
        pageSize   <- map["pageSize"]
        hasPrevious   <- map["hasPrevious"]
        imId <- map["imId"]
    }
}
