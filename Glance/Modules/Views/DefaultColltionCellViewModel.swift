//
//  DefaultColltionCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/6.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DefaultColltionCellViewModel : CellViewModelProtocol ,CollectionCellImageHeightCalculateable {
        
    
    let item : Home
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userName : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let userHeadImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let typeName = BehaviorRelay<String?>(value: nil)
    let time : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let recommended = BehaviorRelay<Bool>(value : false)
    let reactionImage = BehaviorRelay<UIImage?>(value : nil)
    
    
    let userHidden = BehaviorRelay<Bool>(value: false)
    let userOnline = BehaviorRelay<Bool>(value: false)
    let emojiButtonHidden = BehaviorRelay<Bool>(value: false)
    let recommendButtonHidden = BehaviorRelay<Bool>(value: false)
    let saved = BehaviorRelay<Bool>(value: false)

    
    
    let save = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    let userDetail = PublishSubject<Void>()
    let reaction = PublishSubject<UIView>()
        
    var image: String? {
        return item.image
    }

    var col: Int {
        return 2
    }
    
    
    func makeItemType() -> DefaultColltionSectionItem {
        guard let type = item.type else { return .none }
        switch type {
        case .post:
            return .post(viewModel: self)
        case .product:
            return .product(viewModel: self)
        case .recommendPost:
            return .recommendPost(viewModel: self)
        case .recommendProduct:
            return .recommendProduct(viewModel: self)
        }
    }
    
    
    required init(item : Home) {
        self.item = item
        
        guard let type = item.type else { return }
        
        userName.accept(item.user?.displayName)
        userHeadImageURL.accept(item.user?.userImage?.url)
        imageURL.accept(item.image?.url)
        title.accept(item.title)
        userOnline.accept(item.user?.loginStatus ?? false)
        recommended.accept(item.recommended)
        saved.accept(item.saved)
        userHidden.accept(!type.userEnable)
        emojiButtonHidden.accept(!type.emojiEnable)
        recommendButtonHidden.accept(!type.recommendEnable)
        typeName.accept(type.title)
        reactionImage.accept(item.reaction?.image)
        
    }
}
