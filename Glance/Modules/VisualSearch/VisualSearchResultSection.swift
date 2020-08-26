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
    var section : String
    var elements : [VisualSearchResultSectionItem]
}

struct VisualSearchResultSectionItem {
    var item : String
    var viewModel : VisualSearchResultCellViewModel
}

extension VisualSearchResultSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        return item
    }
}
extension VisualSearchResultSectionItem: Equatable {
    static func == (lhs: VisualSearchResultSectionItem, rhs: VisualSearchResultSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension VisualSearchResultSection: AnimatableSectionModelType, IdentifiableType {
    
    typealias Identity = String
    
    typealias Item = VisualSearchResultSectionItem
    
    var identity: Identity { return section }
    
    var items: [Item] {
        return elements
    }
    
    init(original: VisualSearchResultSection, items: [Item]) {
        self = original
        self.elements = items
    }
}

