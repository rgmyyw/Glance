//
//  StyleBoardSearchSection.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//


import UIKit
import RxDataSources
import Differentiator

struct StyleBoardSearchSection {
    var section : Int
    var elements : [StyleBoardSearchSectionItem]
}

struct StyleBoardSearchSectionItem {
    var item : Int
    var viewModel : StyleBoardSearchCellViewModel
}

extension StyleBoardSearchSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        return item.string
    }
}
extension StyleBoardSearchSectionItem: Equatable {
    static func == (lhs: StyleBoardSearchSectionItem, rhs: StyleBoardSearchSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension StyleBoardSearchSection: AnimatableSectionModelType, IdentifiableType {
    
    typealias Item = StyleBoardSearchSectionItem
    
    typealias Identity = String
    var identity: Identity { return section.string }
    
    var items: [Item] {
        return elements
    }
    
    init(original: StyleBoardSearchSection, items: [Item]) {
        self = original
        self.elements = items
    }
}

