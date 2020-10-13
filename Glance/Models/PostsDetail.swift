//
//  PostsDetail.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper



struct PostsDetail: Mappable {
    /// post detail
    var displayName: String?
    var postImage: String?
    var liked: Bool = false
    var lastTimeOnline: Float = 0.0
    var saved: Bool = false

    var shared: Bool = false
    var taggedProducts = [Home]()
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
    var price : String?
    var inShoppingList: Bool = false
    var providerName : String?
    var type : DefaultColltionCellType?
    var description : String?
    
    var id : [String : Any] {
        guard let type = type else { return [:]}
        switch type {
        case .post,.recommendPost:
            return ["postId" : postId]
        case .product,.recommendProduct:
            return ["productId" : productId ?? ""]
        default:
            return [:]
        }
    }

    
    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        displayName   <- map["displayName"]
        postImage   <- map["postImage"]
        liked   <- map["liked"]
        lastTimeOnline   <- map["lastTimeOnline"]
        saved   <- map["saved"]
        shared   <- map["shared"]
        taggedProducts   <- map["taggedProducts"]
        postId   <- map["postId"]
        userImage   <- map["userImage"]
        title   <- map["title"]
        recommended   <- map["recommended"]
        userId   <- map["userId"]
        postsTime <- (map["postsTime"], DateTransform())
        own <- map["own"]
        brand <- map["brand"]
        price <- map["price"]
        productId <- map["productId"]
        image <- map["image"]
        inShoppingList <- map["inShoppingList"]
        providerName <- map["providerName"]
        description <- map["description"]
    }
}
