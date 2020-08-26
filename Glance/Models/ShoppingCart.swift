//
//  ShoppingCart.swift
//  Glance
//
//  Created by yanghai on 2020/7/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import ObjectMapper

struct ShoppingCart: Mappable,Equatable {
    var productId: String?
    var image: String?
    var shoppingLink: String?
    var brand: String?
    var price: String?
    var productTitle: String?
    var currency : String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        productId   <- map["productId"]
        image   <- map["image"]
        shoppingLink   <- map["shoppingLink"]
        brand   <- map["brand"]
        price   <- map["price"]
        productTitle   <- map["productTitle"]
        currency <- map["currency"]
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.productId == rhs.productId
    }
    
}
