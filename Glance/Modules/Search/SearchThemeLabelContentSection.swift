//
//  SearchThemeLabelContentSection.swift
//  Glance
//
//  Created by yanghai on 2020/9/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

enum SearchThemeLabelContentSection {
    case single(items: [DefaultColltionSectionItem])
    case users(items : [DefaultColltionSectionItem])
}

extension SearchThemeLabelContentSection: SectionModelType {

    typealias Item = DefaultColltionSectionItem
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .single(let items):
            return items.map { $0 }
        case .users(let items):
            return items.map { $0 }
        }
    }

    init(original: SearchThemeLabelContentSection, items: [Item]) {
        switch original {
        case .single(let items):
            self = .single(items: items)
        case .users(let items):
            self = .users(items: items)
        }
    }
}
