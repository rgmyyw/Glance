//
//  HomeCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class HomeCellViewModel : CellViewModelProtocol {
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userName : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userHeadImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let typeName = BehaviorRelay<String?>(value: nil)
    let time : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    let userHidden = BehaviorRelay<Bool>(value: false)
    let userOnline = BehaviorRelay<Bool>(value: false)
    let emojiButtonHidden = BehaviorRelay<Bool>(value: false)
    let recommendButtonHidden = BehaviorRelay<Bool>(value: false)
    let isFavorite = BehaviorRelay<Bool>(value: false)

    let saveFavorite = PublishSubject<Void>()
    let showLikePopView = PublishSubject<UIView>()
    
    
    required init(item : Home) {
        self.item = item
        
        guard let type = item.type else { return }
        typeName.accept(type.title)
        
        switch type {
        case .post:
            userName.accept(item.posts?.user?.displayName)
            userHeadImageURL.accept(item.posts?.user?.userImage?.url)
            title.accept(item.posts?.title)
            imageURL.accept(item.posts?.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.posts?.user?.loginStatus ?? false)
            emojiButtonHidden.accept(true)
            isFavorite.accept(item.posts?.saved ?? false)
            recommendButtonHidden.accept(false)
        case .product:
            
            title.accept(item.product?.title)
            imageURL.accept(item.product?.productUrl?.url)
            userHidden.accept(true)
            emojiButtonHidden.accept(true)
            isFavorite.accept(item.product?.saved ?? false)
            recommendButtonHidden.accept(false)
            
        case .recommend:
            userName.accept(item.recommend?.user?.displayName)
            userHeadImageURL.accept(item.recommend?.user?.userImage?.url)
            title.accept(item.recommend?.title)
            imageURL.accept(item.recommend?.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.recommend?.user?.loginStatus ?? false)
            emojiButtonHidden.accept(false)
            isFavorite.accept(item.recommend?.saved ?? false)
            recommendButtonHidden.accept(true)
        }
    }
}
