//
//  InterestCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/22.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class InterestCellViewModel: CellViewModelProtocol {

    let item: Interest
    let imageURL = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)

    let selected = BehaviorRelay<Bool>(value: false)
    let selection = PublishSubject<Void>()

    required init(item: Interest) {

        self.item = item
        self.imageURL.accept(item.image?.url)
        self.title.accept(item.name)
    }

}
