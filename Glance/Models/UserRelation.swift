//
//  UserRelation.swift
//  Glance
//
//  Created by yanghai on 2020/7/13.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct UserRelation : Mappable {
    
    var isFollow: Bool = false
    var isBlocked : Bool = false
    var image: String?
    var userId: String?
    var displayName: String?
    var igHandler: String?
    
    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        isFollow   <- map["isFollow"]
        image   <- map["image"]
        userId   <- map["userId"]
        displayName   <- map["displayName"]
        igHandler   <- map["igHandler"]
        isBlocked <- map["isBlocked"]
    }
}
