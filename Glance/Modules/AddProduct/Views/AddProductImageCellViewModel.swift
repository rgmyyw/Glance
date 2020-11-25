//
//  AddProductCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddProductImageCellViewModel: CellViewModelProtocol {

    let item: UIImage

    let image = BehaviorRelay<UIImage?>(value: nil)

    let edit = PublishSubject<Void>()

    required init(item: UIImage) {
        self.item = item
        image.accept(item)
    }

}
