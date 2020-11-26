//
//  AddProductSection.swift
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

enum AddProductSection {

    case productName(viewModel: AddProductSectionCellViewModel)
    case categary(viewModel: AddProductSectionCellViewModel)
    case tagRelatedKeywords(viewModel: AddProductSectionCellViewModel)
    case brand(viewModel: AddProductSectionCellViewModel)
    case website(viewModel: AddProductSectionCellViewModel)
    case tags(items : [AddProductSectionItem])
    case thumbnail(items :  [AddProductSectionItem])
    case button(viewModel: AddProductSectionCellViewModel)

    var viewModel: AddProductSectionCellViewModel? {
        switch self {
        case .productName(let viewModel),
             .categary(let viewModel),
             .brand(let viewModel),
             .website(let viewModel),
             .tagRelatedKeywords(let viewModel),
             .button(let viewModel):
            return viewModel
        default:
            return nil
        }
    }
}

enum AddProductSectionItem {
    case tag(identity: String, viewModel: AddProductTagCellViewModel)
    case thumbnail(identity: String, viewModel: AddProductImageCellViewModel)

    func viewModel<T: CellViewModelProtocol >(_ type: T.Type) -> T {
        switch self {
        case .tag(_, let viewModel):
            if let viewModel = viewModel as? T {
                return viewModel
            } else {
                fatalError()
            }
        case .thumbnail(_, let viewModel):
            if let viewModel = viewModel as? T {
                return viewModel
            } else {
                fatalError()
            }
        }
    }

}

extension AddProductSection: AnimatableSectionModelType {

    typealias Identity = String
    var identity: String {
        switch self {
        case .brand: return "brand"
        case .button: return "button"
        case .categary: return "categary"
        case .productName: return "productName"
        case .tagRelatedKeywords: return "tagRelatedKeywords"
        case .tags: return "tags"
        case .thumbnail: return "thumbnail"
        case .website: return "website"
        }
    }

    typealias Item = AddProductSectionItem

    var items: [AddProductSectionItem] {
        switch  self {
        case .tags(let items):
            return items.map { $0 }
        case .thumbnail(let items):
            return items.map { $0 }
        default:
            return []
        }
    }

    init(original: AddProductSection, items: [Item]) {
        switch original {
        case .brand(let viewModel):
            self = .brand(viewModel: viewModel)
        case .categary(let viewModel):
            self = .categary(viewModel: viewModel)
        case .productName(let viewModel):
            self = .productName(viewModel: viewModel)
        case .tagRelatedKeywords(let viewModel):
            self = .tagRelatedKeywords(viewModel: viewModel)
        case .tags:
            self = .tags(items: items.map { $0})
        case .website(let viewModel):
            self = .website(viewModel: viewModel)
        case .thumbnail(let items):
            self = .thumbnail( items: items.map { $0})
        case .button(let viewModel):
            self = .button(viewModel: viewModel)
        }
    }
}

extension AddProductSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .tag(let identity, _), .thumbnail(let identity, _):
            return identity
        }
    }
}
extension AddProductSectionItem: Equatable {
    static func == (lhs: AddProductSectionItem, rhs: AddProductSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
