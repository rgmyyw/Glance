//
//  Common.swift
//  ibex
//
//  Created by 杨海 on 2020/4/27.
//  Copyright © 2020 gxd. All rights reserved.
//

import UIKit
import ObjectMapper

struct MappableItem<Item>: Mappable {

    var data: Item?
    var code: Int = -1
    var message: String?

    public init?(map: Map) {}
    
    init() {
        
    }

    mutating public func mapping(map: Map) {
        data  <- map["data"]
        code   <- map["code"]
        message   <- map["msg"]
    }
}


struct PageMapable<Item : Mappable> : Mappable {
    
    var total: Int = 0
    var pageNum: Int = 0
    var list = [Item]()
    var hasNext: Bool = true
    var pageSize: Int = 0
    var hasPrevious: Bool = false

    init?(map: Map) {}
    init(hasNext : Bool = true) {
        self.hasNext = hasNext
    }

    mutating func mapping(map: Map) {
        total   <- map["total"]
        pageNum   <- map["pageNum"]
        list   <- map["records"]
        hasNext   <- map["hasNext"]
        pageSize   <- map["pageSize"]
        hasPrevious   <- map["hasPrevious"]
    }
}
