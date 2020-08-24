//
//  PostsDetail.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper


//struct Data: Mappable {

//
//    init?(map: Map) {}
//
//    mutating func mapping(map: Map) {
//        brand   <- map["brand"]
//        image   <- map["image"]
//        title   <- map["title"]
//        price   <- map["price"]
//        saved   <- map["saved"]
//        liked   <- map["liked"]
//        recommended   <- map["recommended"]
//        inShoppingList   <- map["inShoppingList"]
//        shared   <- map["shared"]
//        productId   <- map["productId"]
//    }
//}

struct PostsDetail: Mappable {
    /// post detail
    var displayName: String?
    var postImage: String?
    var liked: Bool = false
    var lastTimeOnline: Float = 0.0
    var saved: Bool = false

    var shared: Bool = false
    var taggedProducts = [PostsDetailProduct]()
    var postId: Int = 0
    var userImage: String?
    var title: String?
    var recommended: Bool = false
    var userId: String?
    var postsTime : Date?
    var own : Bool = false
        
    /// product detail
    var brand : String?
    var productId : String?
    var image: String?
    var price : Int = 0
    var inShoppingList: Bool = false
    var currency : String?

    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        displayName   <- map["displayName"]
        postImage   <- map["postImage"]
        liked   <- map["liked"]
        lastTimeOnline   <- map["lastTimeOnline"]
        saved   <- map["saved"]
//        similarProducts   <- map["similarProducts"]
        shared   <- map["shared"]
        taggedProducts   <- map["taggedProducts"]
        postId   <- map["postId"]
        userImage   <- map["userImage"]
        title   <- map["title"]
        recommended   <- map["recommended"]
        userId   <- map["userId"]
        postsTime <- (map["postsTime"], ISO8601DateTransform())
        own <- map["own"]
        brand <- map["brand"]
        price <- map["price"]
        productId <- map["productId"]
        image <- map["image"]
        inShoppingList <- map["inShoppingList"]
        currency <- map["currency"]
        
    }
}

struct PostsDetailProduct: Mappable {
    
    var productId: String?
    var saved: Bool = false
    var productUrl: String?
    var title: String?
    var image: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        productId   <- map["productId"]
        saved   <- map["saved"]
        productUrl   <- map["productUrl"]
        title   <- map["title"]
        image   <- map["image"]
    }
}
