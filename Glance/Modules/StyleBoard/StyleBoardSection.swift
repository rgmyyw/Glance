//
//  StyleBoardSection.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import Differentiator

enum StyleBoardSection {

    case images(items : [StyleBoardSectionItem])
}

enum StyleBoardSectionItem {

    case image(viewModel: StyleBoardImageCellViewModel)

    var viewModel: StyleBoardImageCellViewModel {
        switch self {
        case .image(let viewModel):
            return viewModel
        }
    }
}

extension StyleBoardSection: AnimatableSectionModelType {

    typealias Identity = String
    var identity: String {
        switch self {
        case .images: return "images"
        }
    }

    typealias Item = StyleBoardSectionItem

    var items: [StyleBoardSectionItem] {
        switch  self {
        case .images(let items):
            return items
        }
    }

    init(original: StyleBoardSection, items: [Item]) {
        switch original {
        case .images:
            self = .images(items: items)
        }
    }
}

extension StyleBoardSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .image(let viewModel):
            return viewModel.item.productId ?? ""
        }
    }
}
extension StyleBoardSectionItem: Equatable {
    static func == (lhs: StyleBoardSectionItem, rhs: StyleBoardSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
