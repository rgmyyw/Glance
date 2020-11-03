//
//  DefaultColltionItem.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct DefaultColltionItem: Mappable, Equatable {
    
    var title: String?
    var type: DefaultColltionCellType?
    var image: String?
    var user: User?
    var postId: Int = 0
    var productId: String?
    var productUrl: String?
    var recommendId: Int = 0
    var recommended : Bool = false
    var reaction: ReactionType?
    var saved: Bool = false
    var themeId : Int = 0
    var images : [String] = []
    var own : Bool = false
    
    
    
    var id : [String : Any] {
        guard let type = type  else { return [:] }
        var param = [String :Any]()
        switch type {
        case .post,.recommendPost:
            param["postId"] = postId
        case .product,.recommendProduct:
            param["productId"] = productId ?? ""
        case .user:
            param["userId"] = user?.userId ?? ""
        case .theme:
            param["themeId"] = themeId
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
        themeId <- map["themeId"]
        images <- map["images"]
        own <- map["own"]
    }
    
    static func == (lhs: DefaultColltionItem, rhs: DefaultColltionItem) -> Bool {
        guard let ltype = lhs.type ,let rtype = rhs.type else { return  false }
        if ltype != rtype { return false }
        switch ltype {
        case .post,.recommendPost:
            return lhs.postId == rhs.postId
        case .product,.recommendProduct:
            return lhs.productId == rhs.productId
        case .theme:
            return lhs.themeId == rhs.themeId
        case .user:
            return lhs.user?.userId == rhs.user?.userId
        }
    }
    
}



