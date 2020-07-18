//
//  ShoppingCartCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/18.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ShoppingCartCellViewModel: CellViewModelProtocol  {

    let item : ShoppingCart
    let imageURL = BehaviorRelay<URL?>(value: nil)
    let title = BehaviorRelay<String?>(value: nil)
    let price = BehaviorRelay<String?>(value: nil)
    let brand = BehaviorRelay<String?>(value: nil)
    
    let delete = PublishSubject<Void>()
    
    required init(item : ShoppingCart) {
        
        self.item = item
        self.imageURL.accept(item.imUrl?.url)
        self.title.accept(item.productTitle)
        self.price.accept(item.price)
        self.brand.accept(item.brand)
    }

    
}
