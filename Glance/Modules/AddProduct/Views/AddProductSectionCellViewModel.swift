//
//  AddProductSectionCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/5.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddProductSectionCellViewModel: CellViewModelProtocol {

    let item: [Categories]
    let selectedCategoryName = BehaviorRelay<String?>(value: nil)

    let productName = BehaviorRelay<String>(value: "")
    let brand = BehaviorRelay<String>(value: "")
    let website = BehaviorRelay<String>(value: "")

    let addTag = PublishSubject<String>()
    let selectionCategory = PublishSubject<Void>()
    let selectedCategory = BehaviorRelay<Categories?>(value: nil)
    let commit = PublishSubject<Void>()

    let disposeBag = DisposeBag()

    required init(item: [Categories]) {
        self.item = item

        selectedCategory.accept(item.first)
        selectedCategory.map { $0?.name }.bind(to: selectedCategoryName).disposed(by: disposeBag)

    }

}
