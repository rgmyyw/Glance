//
//  SearchRecommendHistorySection.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import Differentiator

struct SearchRecommendHistorySection {
    var section: String
    var elements: [SearchRecommendHistorySectionItem]
}

struct SearchRecommendHistorySectionItem {
    var item: String
    var viewModel: SearchHistoryCellViewModel
}

extension SearchRecommendHistorySectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        return item
    }
}
extension SearchRecommendHistorySectionItem: Equatable {
    static func == (lhs: SearchRecommendHistorySectionItem, rhs: SearchRecommendHistorySectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension SearchRecommendHistorySection: AnimatableSectionModelType, IdentifiableType {

    typealias Item = SearchRecommendHistorySectionItem

    typealias Identity = String
    var identity: Identity { return section }

    var items: [Item] {
        return elements
    }

    init(original: SearchRecommendHistorySection, items: [Item]) {
        self = original
        self.elements = items
    }
}
