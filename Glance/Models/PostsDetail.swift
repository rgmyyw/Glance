//
//  PostsDetail.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct PostsDetail: Mappable {
    var displayName: String?
    var postImage: String?
    var liked: Bool = false
    var lastTimeOnline: Float = 0.0
    var saved: Bool = false
    var similarProducts = [PostsDetailProduct]()
    var shared: Bool = false
    var taggedProducts = [PostsDetailProduct]()
    var postId: Int = 0
    var userImage: String?
    var title: String?
    var recommended: Bool = false
    var userId: String?
    var postsTime : Date?
    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        displayName   <- map["displayName"]
        postImage   <- map["postImage"]
        liked   <- map["liked"]
        lastTimeOnline   <- map["lastTimeOnline"]
        saved   <- map["saved"]
        similarProducts   <- map["similarProducts"]
        shared   <- map["shared"]
        taggedProducts   <- map["taggedProducts"]
        postId   <- map["postId"]
        userImage   <- map["userImage"]
        title   <- map["title"]
        recommended   <- map["recommended"]
        userId   <- map["userId"]
        postsTime <- (map["postsTime"], ISO8601DateTransform())
    }
}

struct PostsDetailProduct: Mappable {
    
    var saved: Bool = false
    var imName: String?
    var imUrl: String?
    var productUrl: String?
    var title : String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        saved   <- map["saved"]
        imName   <- map["imName"]
        imUrl   <- map["imUrl"]
        productUrl   <- map["productUrl"]
        title <- map["title"]
    }
}

