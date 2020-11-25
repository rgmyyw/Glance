//
//  SearchHistoryCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/9/8.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchHistoryCellViewModel: CellViewModelProtocol {

    let item: SearchHistoryItem
    let title = BehaviorRelay<String?>(value: nil)
    let delete = PublishSubject<Void>()

    required init(item: SearchHistoryItem) {
        self.item = item
        title.accept(item.text)
    }

}
