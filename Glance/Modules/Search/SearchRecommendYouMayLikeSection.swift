//
//  SearchRecommendYouMayLikeSection.swift
//  Glance
//
//  Created by yanghai on 2020/9/11.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

enum SearchRecommendYouMayLikeSection {
    case single(items: [DefaultColltionSectionItem])
}


extension SearchRecommendYouMayLikeSection: SectionModelType {
    
    typealias Item = DefaultColltionSectionItem
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .single(let items):
            return items.map { $0}
        }
    }
    
    init(original: SearchRecommendYouMayLikeSection, items: [Item]) {
        switch original {
        case .single(let items):
            self = .single(items: items)
        }
    }
}


