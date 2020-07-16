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


enum PostsDetailSection {
    case head(viewModel : PostsDetailSectionCellViewModel)
    case tagged(viewModel : String, items : [PostsDetailSectionItem])
    case similar(viewModel : String, items :  [PostsDetailSectionItem])
}

enum PostsDetailSectionItem {
    case tagged(viewModel: PostsDetailCellViewModel)
    case similar(viewModel: PostsDetailCellViewModel)
}

extension PostsDetailSection: SectionModelType {
    
    typealias Item = PostsDetailSectionItem
    
    var column : Int {
        switch self {
        case .head:
            return 0
        case .similar:
            return 2
        case .tagged:
            return 3
        }
    }
    
    var items: [PostsDetailSectionItem] {
        switch  self {
        case .tagged(_,let items):
            return items.map { $0 }
        case .similar(_,let items):
            return items.map { $0 }
        case .head:
            return []
        }
    }

    init(original: PostsDetailSection, items: [Item]) {
        switch original {
        case .head(let viewModel):
            self = .head(viewModel: viewModel)
        case .similar(let viewModel, let items):
            self = .similar(viewModel: viewModel, items: items)
        case .tagged(let viewModel, let items):
            self = .tagged(viewModel: viewModel, items: items)
        }
    }
}



