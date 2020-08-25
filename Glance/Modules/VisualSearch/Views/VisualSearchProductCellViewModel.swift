//
//  VisualSearchProductCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/3.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VisualSearchProductCellViewModel : CellViewModelProtocol , CollectionCellImageHeightCalculateable {
    
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    
    
    var image: String? {
        return item.image
    }
    var col: Int {
        return 2
    }
    
    
    required init(item : Home) {
        self.item = item
        
        imageURL.accept(item.image?.url)
    }
}

class VisualSearchProductEmptyCellModel : CellViewModelProtocol {
    
    let item : ()
    let add = PublishSubject<Void>()

    required init(item : ()) {
        self.item = item
    }
}
