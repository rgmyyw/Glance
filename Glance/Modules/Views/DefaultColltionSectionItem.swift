//
//  CellSection.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit


enum DefaultColltionSectionItem {
    
    case none
    case theme(viewModel: DefaultColltionCellViewModel)
    case user(viewModel: DefaultColltionCellViewModel)
    case post(viewModel: DefaultColltionCellViewModel)
    case product(viewModel: DefaultColltionCellViewModel)
    case recommendPost(viewModel: DefaultColltionCellViewModel)
    case recommendProduct(viewModel: DefaultColltionCellViewModel)
    
    
    var reuseIdentifier : String {
        switch self {
        case .none:
            return ""
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
    

    var viewModel : DefaultColltionCellViewModel {
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
            return DefaultColltionCellViewModel(item: Home())
        }
    }
    
    static func register(collectionView : UICollectionView, kinds : [HomeCellType]) {
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
            }
        }
    }
}
