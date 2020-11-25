//
//  SearchThemeModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum SearchThemeContentType: Int {
    case all = -1
    case product = 1
    case post = 0
    case user = 4

}

enum SearchThemeModuleItem {

    case all(viewModel: SearchThemeContentViewModel)
    case product(viewModel: SearchThemeContentViewModel)
    case post(viewModel: SearchThemeContentViewModel)
    case user(viewModel: SearchThemeContentViewModel)

    var defaultTitle: String {
        switch self {
        case .all:
            return "ALL"
        case .product:
            return "Products"
        case .post:
            return "Posts"
        case .user:
            return "Users"
        }
    }

    func toScene(navigator: Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .all(let viewModel):
            return .searchThemeContent(viewModel: viewModel)
        case .post(let viewModel):
            return .searchThemeContent(viewModel: viewModel)
        case .product(let viewModel):
            return .searchThemeContent(viewModel: viewModel)
        case .user(let viewModel):
            return .searchThemeContent(viewModel: viewModel)
        }
    }

}
