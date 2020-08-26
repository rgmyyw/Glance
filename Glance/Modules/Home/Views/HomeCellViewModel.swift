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


class HomeCellViewModel : CellViewModelProtocol ,CollectionCellImageHeightCalculateable {
        
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
    let saved = BehaviorRelay<Bool>(value: false)

    let save = PublishSubject<Void>()
    let showLikePopView = PublishSubject<UIView>()
    
    
    var image: String? {
        return item.image
    }

    var col: Int {
        return 2
    }
    
    required init(item : Home) {
        self.item = item
        
        guard let type = item.type else { return }
        typeName.accept(type.title)
        
        switch type {
        case .post:
            userName.accept(item.user?.displayName)
            userHeadImageURL.accept(item.user?.userImage?.url)
            title.accept(item.title)
            imageURL.accept(item.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.user?.loginStatus ?? false)
            emojiButtonHidden.accept(true)
            saved.accept(item.saved)
            recommendButtonHidden.accept(false)
        case .product:
            
            title.accept(item.title)
            imageURL.accept(item.productUrl?.url)
            userHidden.accept(true)
            emojiButtonHidden.accept(true)
            saved.accept(item.saved)
            recommendButtonHidden.accept(false)
            
        case .recommendPost,.recommendProduct:
            userName.accept(item.user?.displayName)
            userHeadImageURL.accept(item.user?.userImage?.url)
            title.accept(item.title)
            imageURL.accept(item.image?.url)
            userHidden.accept(false)
            userOnline.accept(item.user?.loginStatus ?? false)
            emojiButtonHidden.accept(false)
            saved.accept(item.saved)
            recommendButtonHidden.accept(true)
        }
    }
}
