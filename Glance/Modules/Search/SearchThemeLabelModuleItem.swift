//
//  SearchThemeModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum SearchThemeLabelContentType: Int {
    case all = -1
    case product = 1
    case post = 0

}

enum SearchThemeLabelModuleItem {

    case all(viewModel: SearchThemeLabelContentViewModel)
    case product(viewModel: SearchThemeLabelContentViewModel)
    case post(viewModel: SearchThemeLabelContentViewModel)

    var defaultTitle: String {
        switch self {
        case .all:
            return "ALL"
        case .product:
            return "Products"
        case .post:
            return "Posts"
        }
    }

    func toScene(navigator: Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .all(let viewModel):
            return .searchThemeLabelContent(viewModel: viewModel)
        case .post(let viewModel):
            return .searchThemeLabelContent(viewModel: viewModel)
        case .product(let viewModel):
            return .searchThemeLabelContent(viewModel: viewModel)
        }
    }

}
