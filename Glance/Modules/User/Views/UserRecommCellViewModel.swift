//
//  UserPostCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/10.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class UserRecommCellViewModel : CellViewModelProtocol, CollectionCellImageHeightCalculateable {
    
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let recommendButtonHidden = BehaviorRelay<Bool>(value: false)
    let recommended = BehaviorRelay<Bool>(value: true)
    let saved = BehaviorRelay<Bool>(value: false)

    let save = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    
    var image: String? {
        return item.image
    }
    var col: Int {
        return 2
    }

    
    required init(item : Home) {
        self.item = item

        title.accept(item.title)
        imageURL.accept(item.image?.url)
        recommended.accept(item.recommended)
        saved.accept(item.saved)
        
        
        //recommendButtonHidden.accept(false)
    }
}
