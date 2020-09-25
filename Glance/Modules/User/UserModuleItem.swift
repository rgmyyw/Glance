//
//  UserModuleItem.swift
//  Glance
//
//  Created by yanghai on 2020/9/25.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit

enum UserModuleItem {
    
    case post(viewModel : UserPostViewModel)
    case recommend(viewModel : UserRecommViewModel)
    case followers(viewModel : UserRelationViewModel)
    case following(viewModel : UserRelationViewModel)
    
    var defaultTitle : String {
        switch self {
        case .post:
            return "0\nPosts"
        case .recommend:
            return "0\nRecomm"
        case .followers:
            return "0\nFollowers"
        case .following:
            return "0\nFollowing"
        }
    }
    
    func toScene(navigator : Navigator?) -> Navigator.Scene? {
        guard navigator != nil else {
            return nil
        }
        switch self {
        case .post(let viewModel):
            return .userPost(viewModel: viewModel)
        case .recommend(let viewModel):
            return .userRecommend(viewModel: viewModel)
        case .followers(let viewModel):
            return .userRelation(viewModel: viewModel)
        case .following(let viewModel):
            return .userRelation(viewModel: viewModel)
        }
    }
}

