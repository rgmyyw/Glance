//
//  VisualSearchProductSection.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator


struct VisualSearchProductSection {
    var section : Int
    var elements : [VisualSearchProductSectionItem]
}

struct VisualSearchProductSectionItem {
    var item : Int
    var viewModel : VisualSearchProductCellViewModel
}

extension VisualSearchProductSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        return item.string
    }
}
extension VisualSearchProductSectionItem: Equatable {
    static func == (lhs: VisualSearchProductSectionItem, rhs: VisualSearchProductSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension VisualSearchProductSection: AnimatableSectionModelType, IdentifiableType {
    
    typealias Item = VisualSearchProductSectionItem
    
    typealias Identity = String
    var identity: Identity { return section.string }
    
    var items: [VisualSearchProductSectionItem] {
        return elements
    }
    
    init(original: VisualSearchProductSection, items: [Item]) {
        self = original
        self.elements = items
    }
}

