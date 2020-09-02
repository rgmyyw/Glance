//
//  Reaction.swift
//  Glance
//
//  Created by yanghai on 2020/7/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

enum ReactionType : Int {
    case none = 0
    case heart = 1
    case haha = 2
    case wow = 3
    case sad = 4
    
    
    static var items : [ReactionType] = [.haha,.heart,.wow,.sad]
    
    var image : UIImage? {
        switch self {
        case .none:
            return R.image.icon_reaction_none()
        case .haha:
            return R.image.icon_reaction_haha()
        case .heart:
            return R.image.icon_reaction_heart()
        case .sad:
            return R.image.icon_reaction_sad()
        case .wow:
            return R.image.icon_reaction_wow()
        }
    }
    
}

struct Reaction: Mappable {
    var displayName: String?
    var reactionType: ReactionType?
    var userId: String?
    var isFollow: Bool = false
    var igHandler: String?
    var image: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        displayName   <- map["displayName"]
        reactionType   <- map["reactionType"]
        userId   <- map["userId"]
        isFollow   <- map["isFollow"]
        igHandler   <- map["igHandler"]
        image   <- map["image"]
    }
}
