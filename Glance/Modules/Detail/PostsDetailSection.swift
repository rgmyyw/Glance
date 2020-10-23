//
//  PostsDetail.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import RxDataSources
import RxSwift
import RxCocoa

enum PostsDetailSection  {
    case banner(viewModel : PostsDetailSectionCellViewModel)
    case price(viewModel : PostsDetailSectionCellViewModel)
    case title(viewModel : PostsDetailSectionCellViewModel)
    case tags(viewModel : PostsDetailSectionCellViewModel)
    case tool(viewModel : PostsDetailSectionCellViewModel)
    case tagged(title : String, items : [DefaultColltionSectionItem])
    case similar(title : String, items :  [DefaultColltionSectionItem])
}

extension PostsDetailSection: SectionModelType {
    
    typealias Item = DefaultColltionSectionItem
    
    var column : Int {
        switch self {
        case .similar:
            return 2
        case .tagged:
            return 3
        default:
            return 0
        }
    }
    
    var viewModel : PostsDetailSectionCellViewModel? {
        switch self {
        case .banner(let viewModel),
             .price(let viewModel),
             .tags(let viewModel),
             .title(let viewModel),
             .tool(let viewModel):
            return viewModel
        default:
            return nil
        }

    }
    
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .tagged(_,let items):
            return items.map { $0 }
        case .similar(_,let items):
            return items.map { $0 }
        default:
            return []
        }
    }
    
    init(original: PostsDetailSection, items: [Item]) {
        switch original {
        case .banner(let viewModel):
            self = .banner(viewModel: viewModel)
        case .similar(let title, let items):
            self = .similar(title: title, items: items)
        case .tagged(let title, let items):
            self = .tagged(title: title, items: items)
        case .price(let viewModel):
            self = .price(viewModel: viewModel)
        case .title(let viewModel):
            self = .title(viewModel: viewModel)
        case .tags(let viewModel):
            self = .tags(viewModel: viewModel)
        case .tool(let viewModel):
            self = .tool(viewModel: viewModel)
            
        }
    }
}



