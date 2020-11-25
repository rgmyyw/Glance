//
//  UserDetailPostSection.swift
//  Glance
//
//  Created by yanghai on 2020/10/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

enum UserDetailPostSection {
    case single(items: [DefaultColltionSectionItem])
}

extension UserDetailPostSection: SectionModelType {

    typealias Item = DefaultColltionSectionItem
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .single(let items):
            return items.map { $0 }
        }
    }

    init(original: UserDetailPostSection, items: [Item]) {
        switch original {
        case .single(let items):
            self = .single(items: items)
        }
    }
}
