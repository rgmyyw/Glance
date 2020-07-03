//
//  Version.swift
//  
//
//  Created by 杨海 on 2020/5/13.
//  Copyright © 2020 fwan. All rights reserved.
//

import UIKit
import ObjectMapper

struct Version : Mappable {
    
    var minVersion : String?
    var maxVersion : String?
    var downloadUrl : String?
    
    init?(map: Map) {}

    init () {}
    mutating func mapping(map: Map) {
        
        minVersion   <- map["minVersion"]
        maxVersion <- map["maxVersion"]
        downloadUrl <- map["downloadUrl"]
    }
}
