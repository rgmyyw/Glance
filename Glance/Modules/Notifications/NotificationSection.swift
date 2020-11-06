//
//  NotificationSection.swift
//  Glance-D
//
//  Created by yanghai on 2020/11/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator

enum NotificationSectionItem {

    case following(viewModel: DefaultColltionCellViewModel)
    case liked(viewModel: DefaultColltionCellViewModel)
    case recommended(viewModel: DefaultColltionCellViewModel)
    case reacted(viewModel: DefaultColltionCellViewModel)
    case mightLike(viewModel: DefaultColltionCellViewModel)
    case system(viewModel: DefaultColltionCellViewModel)
    case theme(viewModel: DefaultColltionCellViewModel)
    

    var viewModel : DefaultColltionCellViewModel {
        switch self {
        case .following(let viewModel):
            return viewModel
        case .liked(let viewModel):
            return viewModel
        case .recommended(let viewModel):
            return viewModel
        case .reacted(let viewModel):
            return viewModel
        case .mightLike(let viewModel):
            return viewModel
        case .system(let viewModel):
            return viewModel
        case .theme(let viewModel):
            return viewModel
        }
    }
    
    static func register(collectionView : UICollectionView, kinds : [DefaultColltionCellType]) {
        kinds.forEach { (type) in
            switch type {
            case .post:
                collectionView.register(nibWithCellClass: PostCell.self)
            case .product:
                collectionView.register(nibWithCellClass: ProductCell.self)
            case .recommendPost:
                collectionView.register(nibWithCellClass: PostRecommendCell.self)
            case .recommendProduct:
                collectionView.register(nibWithCellClass: ProductRecommendCell.self)
            case .theme:
                collectionView.register(nibWithCellClass: ThemeCell.self)
            case .user:
                collectionView.register(nibWithCellClass: UserVerticalCell.self)
            }
        }
    }
}

extension NotificationSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .following(let viewModel):
            return viewModel.item.productId ?? ""
        default:
            return ""
        }
    }
}
extension NotificationSectionItem: Equatable {
    static func == (lhs: NotificationSectionItem, rhs: NotificationSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
