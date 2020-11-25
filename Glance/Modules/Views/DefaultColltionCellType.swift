//
//  DefaultColltionCellType.swift
//  Glance
//
//  Created by yanghai on 2020/9/15.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum DefaultColltionCellType: Int {

    static let all: [DefaultColltionCellType] = [.post, .product, .recommendPost, .recommendProduct, .user, .theme]

    case post = 0
    case product = 1
    case recommendPost = 2
    case recommendProduct = 3
    case user = 4
    case theme = 5
}

extension DefaultColltionCellType {

    /// 判断是否为post 还是 商品
    var isPost: Bool { return !isProduct }

    var isProduct: Bool {
        switch self {
        case .post, .recommendPost:
            return false
        default:
            return true
        }
    }
}
