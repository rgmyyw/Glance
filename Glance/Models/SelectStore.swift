//
//  SelectStore.swift
//  Glance
//
//  Created by yanghai on 2020/9/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import ObjectMapper

struct SelectStore: Mappable {
    var availability: String?
    var variants: String?
    var inShoppingList: Bool = false
    var productId: String?
    var providerName: String?
    var image: String?
    var price: String?
    var title: String?
    var productUrl: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        availability   <- map["availability"]
        variants   <- map["variants"]
        inShoppingList   <- map["inShoppingList"]
        productId   <- map["productId"]
        providerName   <- map["providerName"]
        image   <- map["image"]
        price   <- map["price"]
        title   <- map["title"]
        productUrl <- map["productUrl"]
    }
}
