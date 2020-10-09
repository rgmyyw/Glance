//
//  UserRecommSection.swift
//  Glance-D
//
//  Created by yanghai on 2020/10/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

enum UserRecommSection {
    case single(items: [DefaultColltionSectionItem])
}


extension UserRecommSection: SectionModelType {
    
    typealias Item = DefaultColltionSectionItem
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .single(let items):
            return items.map { $0 }
        }
    }
    
    init(original: UserRecommSection, items: [Item]) {
        switch original {
        case .single(let items):
            self = .single(items: items)
        }
    }
}

