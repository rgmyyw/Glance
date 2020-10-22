//
//  ErrorResponse.swift
//  
//
//  Created by yanghai on 1/28/19.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import ObjectMapper

struct ErrorResponse: Mappable {
    var message: String?
    var errors: [ErrorModel] = []
    var documentationUrl: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        message <- map["message"]
        errors <- map["errors"]
        documentationUrl <- map["documentation_url"]
    }

    func detail() -> String {
        return errors.map { $0.message ?? "" }
        .joined(separator: errors.count > 1 ? "\n" : "")
    }
}

struct ErrorModel: Mappable {
    var code: String?
    var message: String?

    init?(map: Map) {}
    init() {}

    mutating func mapping(map: Map) {
        code <- map["code"]
        message <- map["msg"]
    }
}
