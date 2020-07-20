//
//  SavedCollection.swift
//  Glance
//
//  Created by yanghai on 2020/7/20.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct SavedCollection: Mappable {
    var classifyName: String?
    var savedCount: Int = 0
    var imageList = [String]()

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        classifyName   <- map["classifyName"]
        savedCount   <- map["savedCount"]
        imageList   <- map["imageList"]
    }
}
