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
    let edit = PublishSubject<Void>()
    
    var size : CGSize {
        if let size = item.image?.urlImageSize() {
            let maxH : CGFloat = UIScreen.main.bounds.width * 0.5
            var w = UIScreen.main.bounds.width
            var h = w * size.height / size.width
            if h > maxH {
                h = maxH
                w = h * size.width / size.height
            }
            return CGSize(width: w, height: h)
            
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
