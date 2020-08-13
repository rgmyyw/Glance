//
//  StyleBoardSearchCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class StyleBoardSearchCellViewModel : CellViewModelProtocol, CollectionCellImageHeightCalculateable {
    
    var col: Int {
        return 2
    }
    
    
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let selected = BehaviorRelay<Bool>(value: false)
    
    let selection = PublishSubject<Void>()
    
    
    var image: String? {
        return item.image
    }
        
    
    required init(item : Home) {
        self.item = item
        
        imageURL.accept(item.image?.url)
        title.accept(item.title)
    }
}
