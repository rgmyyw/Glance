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
    
    var boxes : [Box] {
        return boxProducts.compactMap { $0.box}
    }
    

    init?(map: Map) {}
    init() {}
    
    init(boxProduct : BoxProducts) {
        self.boxProducts = [boxProduct]
        self.pageNum = 1
        self.pageSize = 10
    }

    mutating func mapping(map: Map) {
        boxProducts   <- map["boxProducts"]
        pageNum   <- map["pageNum"]
        imId   <- map["imId"]
        pageSize   <- map["pageSize"]
        
    }
}


struct BoxProducts: Mappable {
    var score: Int = 0
    var productList = [DefaultColltionItem]()
    var box : Box?
    var type: String?
    var total: Int = 0
    var pageNum: Int = 0
    var hasNext : Bool = true
    
    
    var selected : DefaultColltionItem?
    var system : Bool = false
    
    var refreshState : RefreshState {
        if pageNum == 1 {
            if productList.isEmpty {
                return .disable
            } else if hasNext {
                return .enable
            } else {
                return .noMoreData
            }
        } else {
            if hasNext {
                return .enable
            } else {
                return .noMoreData
            }
        }
    }
    
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        score   <- map["score"]
        productList   <- map["productList"]
        box   <- (map["box"] , BoxTransform())
        type   <- map["type"]
        total   <- map["total"]
        hasNext <- map["hasNext"]
    }
}
