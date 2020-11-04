//
//  PostProductSection.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Differentiator

enum PostProductSection  {
    
    case caption(viewModel : PostProductSectionCellViewModel)
    case tagRelatedKeywords(viewModel : PostProductSectionCellViewModel)
    case customTags(items : [PostProductSectionItem])
    case systemTags(title : String,items :  [PostProductSectionItem])
    case tagged(title : String,items :  [PostProductSectionItem])

    
    var viewModel : PostProductSectionCellViewModel? {
        switch self {
        case .caption(let viewModel),
             .tagRelatedKeywords(let viewModel):
             return viewModel
        default:
            return nil
        }
    }
}

enum PostProductSectionItem {
    
    case tag(viewModel: PostProductTagCellViewModel)
    case product(viewModel: PostProductCellViewModel)

    func viewModel<T : CellViewModelProtocol >(_ type: T.Type) -> T {
        switch self {
        case .tag(let viewModel):
            return viewModel as! T
        case .product(let viewModel):
            return viewModel as! T
        }
    }

}


extension PostProductSection: AnimatableSectionModelType {
    
    typealias Identity = String
    var identity: String {
        switch self {
        case .caption: return "caption"
        case .tagRelatedKeywords: return "tagRelatedKeywords"
        case .customTags: return "customTags"
        case .systemTags: return "systemTags"
        case .tagged: return "tagged"
        }
    }
    
    typealias Item = PostProductSectionItem
    
    var items: [PostProductSectionItem] {
        switch  self {
        case .customTags(let items),.systemTags(_,let items),.tagged(_,let items):
            return items.map { $0 }
        default:
            return []
        }
    }

    
    init(original: PostProductSection, items: [Item]) {
        switch original {
        case .caption(let viewModel):
            self = .caption(viewModel: viewModel)
        case .tagRelatedKeywords(let viewModel):
            self = .tagRelatedKeywords(viewModel: viewModel)
        case .customTags:
            self = .customTags(items: items)
        case .systemTags(let title, _):
            self = .systemTags(title: title,items: items)
        case .tagged(let title, _):
            self = .tagged(title: title,items: items)
        }
    }
}


extension PostProductSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .tag(let viewModel):
            return viewModel.item
        case .product(let viewModel):
            return viewModel.item.productId ?? ""
        }
    }
}
extension PostProductSectionItem: Equatable {
    static func == (lhs: PostProductSectionItem, rhs: PostProductSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}


