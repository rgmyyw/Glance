//
//  SearchThemeLabelCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class SearchThemeLabelCellViewModel: CellViewModelProtocol  {

    let item : SearchThemeDetailLabel
    let title = BehaviorRelay<String?>(value: nil)
    let delete = PublishSubject<Void>()
    
    
    required init(item : SearchThemeDetailLabel) {
        self.item = item
        title.accept(item.name)
    }

}
