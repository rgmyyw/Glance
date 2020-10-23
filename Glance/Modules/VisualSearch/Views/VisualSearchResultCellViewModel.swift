//
//  VisualSearchResultCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/30.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VisualSearchResultCellViewModel : CellViewModelProtocol, CollectionCellImageHeightCalculateable {
        
    let item : DefaultColltionItem
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let selected = BehaviorRelay<Bool>(value: false)
    
    let selection = PublishSubject<Void>()
    
    
    var image: String? {
        return item.image
    }
        
    
    required init(item : DefaultColltionItem) {
        self.item = item
        
        imageURL.accept(item.image?.url)
        title.accept(item.title)
    }
}
