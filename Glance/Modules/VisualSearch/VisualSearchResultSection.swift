//
//  VisualSearchResultSection.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator

struct VisualSearchResultSection {
    var section : Int
    var elements : [VisualSearchResultSectionItem]
}

struct VisualSearchResultSectionItem {
    var item : Int
    var viewModel : VisualSearchResultCellViewModel
    
    
}

extension VisualSearchResultSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        return item.string
    }
}
extension VisualSearchResultSectionItem: Equatable {
    static func == (lhs: VisualSearchResultSectionItem, rhs: VisualSearchResultSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension VisualSearchResultSection: AnimatableSectionModelType, IdentifiableType {
    
    typealias Item = VisualSearchResultSectionItem
    
    typealias Identity = String
    var identity: Identity { return section.string }
    
    var items: [Item] {
        return elements
    }
    
    init(original: VisualSearchResultSection, items: [Item]) {
        self = original
        self.elements = items
    }
}

