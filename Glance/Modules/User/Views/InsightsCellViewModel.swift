//
//  InsightsCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/14.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InsightsCellViewModel: CellViewModelProtocol {

    let item: Insight
    let imageURL: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let reachCount: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let interactionsCount: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let time: BehaviorRelay<String?> = BehaviorRelay(value: nil)

    required init(item: Insight) {
        self.item = item
        title.accept(item.title)
        imageURL.accept(item.image?.url)
        reachCount.accept(item.reachCount.string)
        interactionsCount.accept(item.interactionsCount.string)
        time.accept(item.created?.dateString(ofStyle: .medium))
    }
}
