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
        
        typeName.accept(item.type.title)
        
//        var item = item
//        item.image = "https://img14.360buyimg.com/n0/jfs/t1/114746/7/9219/113962/5ed8dc5aEb58f859d/623d77ec2b96bfee.jpg"
//        item.productUrl = item.image
        
        switch item.type {
        case .post:
            userName.accept(item.user?.displayName)
            userHeadImageURL.accept(item.user?.userImage?.url)
            title.accept(item.title)
            imageURL.accept(item.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.user?.loginStatus ?? false)
            emojiButtonHidden.accept(true)
            isFavorite.accept(item.saved)
            recommendButtonHidden.accept(false)
        case .product:
            
            title.accept(item.title)
            imageURL.accept(item.productUrl?.url)
            userHidden.accept(true)
            emojiButtonHidden.accept(true)
            isFavorite.accept(item.saved)
            recommendButtonHidden.accept(false)
            
        case .recommendPost,.recommendProduct:
            userName.accept(item.user?.displayName)
            userHeadImageURL.accept(item.user?.userImage?.url)
            title.accept(item.title)
            imageURL.accept(item.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.user?.loginStatus ?? false)
            emojiButtonHidden.accept(false)
            isFavorite.accept(item.saved)
            recommendButtonHidden.accept(true)
        }
    }
}
