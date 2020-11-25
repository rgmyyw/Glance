//
//  SearchRecommendModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum SearchRecommendModuleItem {

    case hot(viewModel: SearchRecommendHotViewModel)
    case youMayLike(viewModel: SearchRecommendYouMayLikeViewModel)
    case new(viewModel: SearchRecommendNewViewModel)

    var defaultTitle: String {
        switch self {
        case .hot:
            return "Hot"
        case .youMayLike:
            return "You May Like"
        case .new:
            return "New"
        }
    }

    func toScene(navigator: Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .hot(let viewModel):
            return .searchRecommendHot(viewModel: viewModel)
        case .youMayLike(let viewModel):
            return .searchRecommendYouMayLike(viewModel: viewModel)
        case .new(let viewModel):
            return .searchRecommendNew(viewModel: viewModel)
        }
    }
}
