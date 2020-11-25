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

enum VisualSearchResultSection {
    case picker(items: [DefaultColltionSectionItem])
    case preview(items: [DefaultColltionSectionItem])
}

extension VisualSearchResultSection: SectionModelType, AnimatableSectionModelType, IdentifiableType {

    var identity: String {
        switch self {
        case .picker:
            return "picker"
        case .preview:
            return "preview"
        }
    }

    typealias Identity = String

    typealias Item = DefaultColltionSectionItem
    var items: [DefaultColltionSectionItem] {
        switch  self {
        case .picker(let items), .preview(let items):
            return items.map { $0 }
        }
    }

    init(original: VisualSearchResultSection, items: [Item]) {
        switch original {
        case .picker(let items):
            self = .picker(items: items)
        case .preview(let items):
            self = .preview(items: items)

        }
    }
}
