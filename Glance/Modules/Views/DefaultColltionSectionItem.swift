//
//  CellSection.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator

enum DefaultColltionSectionItem {

    case none
    case theme(viewModel: DefaultColltionCellViewModel)
    case user(viewModel: DefaultColltionCellViewModel)
    case post(viewModel: DefaultColltionCellViewModel)
    case product(viewModel: DefaultColltionCellViewModel)
    case recommendPost(viewModel: DefaultColltionCellViewModel)
    case recommendProduct(viewModel: DefaultColltionCellViewModel)

    var reuseIdentifier: String {
        switch self {
        case .none:
            fatalError()
        case .post:
            return PostCell.reuseIdentifier
        case .product:
            return ProductCell.reuseIdentifier
        case .recommendPost:
            return PostRecommendCell.reuseIdentifier
        case .recommendProduct:
            return ProductRecommendCell.reuseIdentifier
        case .theme:
            return ThemeCell.reuseIdentifier
        case .user:
            return UserVerticalCell.reuseIdentifier
        }
    }

    var viewModel: DefaultColltionCellViewModel {
        switch self {
        case .theme(let viewModel):
            return viewModel
        case .user(let viewModel):
            return viewModel
        case .post(let viewModel):
            return viewModel
        case .product(let viewModel):
            return viewModel
        case .recommendPost(let viewModel):
            return viewModel
        case .recommendProduct(let viewModel):
            return viewModel
        case .none:
            fatalError()
        }
    }

    static func register(collectionView: UICollectionView, kinds: [DefaultColltionCellType]) {
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
extension DefaultColltionSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .none:
            fatalError()
        case .post(let viewModel):
            return "postId:\(viewModel.item.postId)"
        case .product(let viewModel):
            return "productId:\(viewModel.item.productId ?? "")"
        case .recommendPost(let viewModel):
            return "recommendId:\(viewModel.item.recommendId)-post"
        case .recommendProduct(let viewModel):
            return "recommendId:\(viewModel.item.recommendId)-product"
        case .theme(let viewModel):
            return "themeId:\(viewModel.item.themeId)"
        case .user(let viewModel):
            return "userId:\(viewModel.item.user?.userId ?? "")"
        }
    }
}
extension DefaultColltionSectionItem: Equatable {
    static func == (lhs: DefaultColltionSectionItem, rhs: DefaultColltionSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
