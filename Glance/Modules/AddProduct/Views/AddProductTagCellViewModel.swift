//
//  AddProductTagCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/4.
//  Copyright © 2020 yanghai. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class AddProductTagCellViewModel: CellViewModelProtocol  {

    let item : String
  
    let title = BehaviorRelay<String?>(value: nil)
    let delete = PublishSubject<Void>()
    let selected = BehaviorRelay<Bool>(value: false)

    
    required init(item : String) {
        self.item = item
        self.title.accept(item)
    }

}
