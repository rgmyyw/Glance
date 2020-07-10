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

class UserPostCellViewModel : CellViewModelProtocol {
    
    let item : Posts
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let emojiButtonHidden = BehaviorRelay<Bool>(value: false)
    let recommendButtonHidden = BehaviorRelay<Bool>(value: false)
    let isFavorite = BehaviorRelay<Bool>(value: false)

    let saveFavorite = PublishSubject<Void>()
    let showLikePopView = PublishSubject<UIView>()
    
    
    required init(item : Posts) {
        self.item = item
        

        title.accept(item.title)
        imageURL.accept(item.image?.url)
        emojiButtonHidden.accept(true)
        recommendButtonHidden.accept(false)

    }
}
