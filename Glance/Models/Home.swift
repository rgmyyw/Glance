//
//  Home.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper


enum HomeCellType : Int {
    case post = 0
    case product = 1
    case recommend = 2
    
    var title : String {
        switch self {
        case .post:
            return "posted"
        case .product:
            return ""
        case .recommend:
            return "recommended"
        }
    }
}




struct Home: Mappable {
    var product: Product?
    var type: HomeCellType?
    var posts: Posts?
    var recommend: Recommend?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        product   <- map["product"]
        type   <- map["type"]
        posts   <- map["posts"]
        recommend   <- map["recommend"]
    }
}

struct Recommend: Mappable {
    var type: Float = 0.0
    var productId: Float = 0.0
    var user: User?
    var image: String?
    var title: String?
    var saved: Bool = false
    var recommendId: Float = 0.0
    var reaction: Float = 0.0
    var postId: Float = 0.0

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        type   <- map["type"]
        productId   <- map["productId"]
        user   <- map["user"]
        image   <- map["image"]
        title   <- map["title"]
        saved   <- map["saved"]
        recommendId   <- map["recommendId"]
        reaction   <- map["reaction"]
        postId   <- map["postId"]
    }
}


struct Posts: Mappable {
    var image: String?
    var title: String?
    var saved: Bool = false
    var postId: Float = 0.0
    var user: User?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        image   <- map["image"]
        title   <- map["title"]
        saved   <- map["saved"]
        postId   <- map["postId"]
        user   <- map["user"]
    }
}



struct Product: Mappable {
    var title: String?
    var productUrl: String?
    var imName: String?
    var saved: Bool = false
    var imUrl: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        title   <- map["title"]
        productUrl   <- map["productUrl"]
        imName   <- map["imName"]
        saved   <- map["saved"]
        imUrl   <- map["imUrl"]
    }
}
