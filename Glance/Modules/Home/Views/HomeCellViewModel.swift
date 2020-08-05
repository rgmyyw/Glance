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
    
    
    var col : CGFloat = 2
    
    var height : CGFloat {
        let inset : CGFloat = 20
        let cellWidth : CGFloat = UIScreen.width - (inset * 2.0) - ((col - 1.0) * 15.0)
        if let urlParameters = item.image?.urlParameters() {
            let width = urlParameters["w"]?.cgFloat() ?? 0
            let height = urlParameters["h"]?.cgFloat() ?? 0
            return ((cellWidth / width) * height) / col
        } else {
            return 200
        }
    }

    
    required init(item : Home) {
        self.item = item
        
        typeName.accept(item.type.title)

        
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
