//
//  VisualSearch.swift
//  Glance
//
//  Created by yanghai on 2020/7/31.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct VisualSearchPageMapable: Mappable {
    var boxProducts = [BoxProducts]()
    var pageNum: Int = 0
    var imId: String?
    var pageSize: Int = 0

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        boxProducts   <- map["boxProducts"]
        pageNum   <- map["pageNum"]
        imId   <- map["imId"]
        pageSize   <- map["pageSize"]

    }
}


struct BoxProducts: Mappable {
    var score: Int = 0
    var productList = [Home]()
    var box : [Int] = [Int]()
    var type: String?
    var total: Int = 0
    var pageNum: Int = 0
    

    
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        score   <- map["score"]
        productList   <- map["productList"]
        box   <- map["box"]
        type   <- map["type"]
        total   <- map["total"]
    }
}
