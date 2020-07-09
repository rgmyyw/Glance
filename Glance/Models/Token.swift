//
//  Token.swift
//  
//
//  Created by yanghai on 2019/11/20.
//  Copyright © 2020 fwan. All rights reserved.
//

import Foundation
import ObjectMapper

enum TokenType {
    case basic(token: String)
    case unauthorized
    var description: String {
        switch self {
        case .basic: return "basic"
        case .unauthorized: return "unauthorized"
        }
    }
}

struct Token: Mappable {

    var isValid = true
    

    // Basic
    var basicToken: String?
    
    var expired : Int = 0

    
    init?(map: Map) {}
    init() {}

    init(basicToken: String) {
        self.basicToken = basicToken
    }

    mutating func mapping(map: Map) {
        isValid <- map["valid"]
        basicToken <- map["token"]
        expired <- map["expired"]
    }

    func type() -> TokenType {
        if let token = basicToken {
            return .basic(token: token)
        }
        return .unauthorized
    }
}
