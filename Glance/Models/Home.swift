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
    
    
    static let all : [HomeCellType] = [.post,.product,.recommendPost,.recommendProduct]
    
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

/// 判断是否为post 还是 商品
extension HomeCellType {
    
    var isPost : Bool { return !isProduct }
    
    var isProduct : Bool {
        switch self {
        case .post,.recommendPost:
            return false
        default:
            return true
        }
    }
}


/// 首页
extension HomeCellType {
    
    /// 详情页, 首页显示用户是否显示头像
    var userEnable : Bool {
        switch self {
        case .post,.recommendPost:
            return true
        default:
            return false
        }
    }
    
    /// emoji 表情是否显示
    var emojiEnable : Bool {
        switch self {
        case .post,.product:
            return false
        default:
            return true
        }
    }
    
    /// emoji 表情是否显示
    var recommendEnable : Bool {
        switch self {
        case .post,.product:
            return true
        default:
            return false
        }
    }

}






struct Home: Mappable, Equatable {
    
    var title: String?
    var type: HomeCellType?
    var image: String?
    
    var user: User?
        
    var postId: Int = 0
    
    var productId: String?
    var productUrl: String?
    
    var recommendId: Int = 0
    var recommended : Bool = false
    var reaction: ReactionType?
    
    var saved: Bool = false
    
    
    var id : [String : Any] {
        guard let type = type  else { return [:] }
        var param = [String :Any]()
        switch type {
        case .post,.recommendPost:
            param["postId"] = postId
        case .product,.recommendProduct:
            param["productId"] = productId ?? ""
        }
        if recommendId > 0  {
            param["recommendId"] = recommendId
        }
        return param
    }
    
    init(productId : String) {
        self.productId = productId
        self.type = .product
    }
    
    init(postId : Int) {
        self.postId = postId
        self.type = .post
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
        recommended <- map["recommended"]
        reaction <- map["reactionType"]
    }
    
    static func == (lhs: Home, rhs: Home) -> Bool {
        guard let ltype = lhs.type ,let rtype = rhs.type else { return  false }
        if ltype != rtype { return false }
        switch ltype {
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
