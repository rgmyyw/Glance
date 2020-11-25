//
//  SearchCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchCellViewModel: CellViewModelProtocol {

    let item : (source: String, target: SearchFacet)

    let attr = BehaviorRelay<NSAttributedString?>(value: nil)

    required init(item : (source: String, target: SearchFacet)) {
        self.item = item
        let text = item.target.facets ?? ""

        let attribute = NSMutableAttributedString(string: text, attributes: [.font: UIFont.titleFont(14), .foregroundColor: UIColor.text()])
        attribute.addAttribute(.foregroundColor, value: UIColor.primary(), range: text.nsString.range(of: item.source))
        attr.accept(attribute)
    }
}
