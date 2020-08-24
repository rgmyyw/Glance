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
    case recommendPost = 2
    case recommendProduct = 3
    
    var title : String {
        switch self {
        case .post:
            return "posted"
        case .product:
            return ""
        case .recommendPost:
            return "recommended"
        case .recommendProduct:
            return "recommended"
        }
    }
}

struct Home: Mappable, Equatable {
    
    var saved: Bool = false
    var user: User?
    var image: String?
    
    var title: String?
    var type: HomeCellType = .product
    
    var postId: Int = 0
    var recommendId: Int = 0
    var productId: String?
    
    var productUrl: String?
    var reaction: Int = 0
    
    var id : Any {
        switch type {
        case .post,.recommendPost:
            return postId
        case .product,.recommendProduct:
            return productId ?? ""
        }
    }
    
    
    var isProduct : Bool {
        switch type {
        case .post,.recommendPost:
            return false
        case .product,.recommendProduct:
            return true
        }
    }
    var isPost : Bool {
        return !isProduct
    }
    
    
    init(productId : String) {
        self.productId = productId
        self.type = .product
    }
    

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        saved   <- map["saved"]
        user   <- map["user"]
        image   <- map["image"]
        title   <- map["title"]
        type   <- map["type"]
        postId   <- map["postId"]
        recommendId   <- map["recommendId"]
        productId   <- map["productId"]
        productUrl   <- map["productUrl"]
        reaction   <- map["reaction"]
    }
    
    static func == (lhs: Home, rhs: Home) -> Bool {
        if lhs.type != rhs.type { return false }
        switch lhs.type {
        case .post,.recommendPost:
            return lhs.postId == rhs.postId
        case .product,.recommendProduct:
            return lhs.productId == rhs.productId
        }
    }
    
}

//
//
//struct Home: Mappable {
//    var product: Product?
//    var type: HomeCellType?
//    var posts: Posts?
//    var recommend: Recommend?
//    var postId : Int = 77
//
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        product   <- map["product"]
//        type   <- map["type"]
//        posts   <- map["posts"]
//        recommend   <- map["recommend"]
//    }
//}
//
//struct Recommend: Mappable {
//
//    var type: HomeCellType?
//    var productId: Int = 0
//    var user: User?
//    var image: String?
//    var title: String?
//    var saved: Bool = false
//    var reaction: Int = 0
//
//
//    var postId: Int = 0
//    var recommendId: Int = 0
//
//    init?(map: Map) {}
//    init() {}
//
//    mutating func mapping(map: Map) {
//        type   <- map["type"]
//        productId   <- map["productId"]
//        user   <- map["user"]
//        image   <- map["image"]
//        title   <- map["title"]
//        saved   <- map["saved"]
//        recommendId   <- map["recommendId"]
//        reaction   <- map["reaction"]
//        postId   <- map["postId"]
//    }
//}
//
//
//struct Posts: Mappable {
//    var image: String?
//    var title: String?
//    var saved: Bool = false
//    var postId: Int = 0
//    var user: User?
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        image   <- map["image"]
//        title   <- map["title"]
//        saved   <- map["saved"]
//        postId   <- map["postId"]
//        user   <- map["user"]
//    }
//}



//struct Product: Mappable {
//    var title: String?
//    var productUrl: String?
//    var imName: String?
//    var saved: Bool = false
//    var imUrl: String?
//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        title   <- map["title"]
//        productUrl   <- map["productUrl"]
//        imName   <- map["imName"]
//        saved   <- map["saved"]
//        imUrl   <- map["imUrl"]
//    }
//}
