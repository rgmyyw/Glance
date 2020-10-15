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
import Kingfisher

class StyleBoardImageCellViewModel: CellViewModelProtocol  {

    let item : DefaultColltionItem
    
    let image = BehaviorRelay<URL?>(value: nil)
    let empty = BehaviorRelay<Bool>(value : true)
    
    let add = PublishSubject<Void>()
    let delete = PublishSubject<Void>()
    let edit = PublishSubject<Void>()
    
    
    func resize(size : CGSize) -> CGSize{
        let maxH : CGFloat = UIScreen.main.bounds.width * 0.5
        var w = UIScreen.main.bounds.width
        var h = w * size.height / size.width
        if h > maxH {
            h = maxH
            w = h * size.width / size.height
        }
        return CGSize(width: w, height: h)
    }
    
    var size : CGSize {
        if let size = item.image?.urlImageSize() , size != .zero {
            return resize(size: size)
        } else if let url = item.image , let image = ImageCache.default.retrieveImageInMemoryCache(forKey: url){
            return  resize(size: image.size)
        } else {
            return CGSize(width: 200, height: 200)
        }
    }
    
    
    required init(item : DefaultColltionItem) {
        self.item = item
        self.image.accept(item.image?.url)
        self.empty.accept(item.productId != nil && item.productId == "-1")
    }

}
