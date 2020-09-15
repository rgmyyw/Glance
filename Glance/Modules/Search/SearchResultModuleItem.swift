//
//  SearchResultModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum SearchResultContentType {
    case all
    case product
    case post
    case user
}


enum SearchResultModuleItem {
    
    case all(viewModel : SearchResultContentViewModel)
    case product(viewModel : SearchResultContentViewModel)
    case post(viewModel : SearchResultContentViewModel)
    case user(viewModel : SearchResultContentViewModel)
    
    var defaultTitle : String {
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
    
    func toScene(navigator : Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .all(let viewModel):
            return .searchResultContent(viewModel: viewModel)
        case .post(let viewModel):
            return .searchResultContent(viewModel: viewModel)
        case .product(let viewModel):
            return .searchResultContent(viewModel: viewModel)
        case .user(let viewModel):
            return .searchResultContent(viewModel: viewModel)
        }
    }

}
