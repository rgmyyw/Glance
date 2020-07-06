//
//  HomeSection.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

enum HomeSection {
    case recommend(items: [HomeSectionItem])
}

enum HomeSectionItem {
    case recommendItem(viewModel: HomeCellViewModel)
}

extension HomeSection: SectionModelType {
    
    typealias Item = HomeSectionItem
    
    
    var items: [HomeSectionItem] {
        switch  self {
        case .recommend(let items):
            return items.map { $0 }
        }
    }
    
    init(original: HomeSection, items: [Item]) {
        switch original {
        case .recommend(let items):
            self = .recommend(items: items)
        }
    }
}



