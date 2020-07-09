//
//  BlockedCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/9.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BlockedCellViewModel: CellViewModelProtocol {

    let item : Notice
    let title = BehaviorRelay<String?>(value: nil)
    let selected = BehaviorRelay<Bool>(value: false)
    
    required init(item : Notice) {
        
        self.item = item
//        self.title.accept(item.name)
//        self.selected.accept(item.isDefault)
    }

    
}
