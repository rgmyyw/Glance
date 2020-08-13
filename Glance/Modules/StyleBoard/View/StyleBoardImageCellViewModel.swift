//
//  StyleBoardImageCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/8/12.
//  Copyright © 2020 yanghai. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

class StyleBoardImageCellViewModel: CellViewModelProtocol  {

    let item : Home
    
    let image = BehaviorRelay<URL?>(value: nil)
    let empty = BehaviorRelay<Bool>(value : true)
    
    let add = PublishSubject<Void>()
    let delete = PublishSubject<Void>()
    
    var size : CGSize {
        if var size = item.image?.urlImageSize() {
            size.width = size.width * 0.2
            size.height = size.height * 0.2
            return size
            
        } else {
            return .zero
        }
    }
    
    
    required init(item : Home) {
        self.item = item
        self.image.accept(item.image?.url)
        self.empty.accept(item.productId != nil && item.productId == "-1")
    }

}
