//
//  UploadImageType.swift
//  Glance
//
//  Created by yanghai on 2020/9/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

enum UploadImageType: Int {
    case visualSearch = 0
    case post = 1
    case postDraft = 2
    case user = 3
}

struct UploadImageResult: Mappable {
    var imageUri: String?
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        imageUri   <- map["imageUri"]
    }
}
