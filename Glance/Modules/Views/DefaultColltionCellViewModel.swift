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
    let displayName = BehaviorRelay<String?>(value: nil)
    let userHeadImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let time : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let recommended = BehaviorRelay<Bool>(value : false)
    let reactionImage = BehaviorRelay<UIImage?>(value : nil)
    let userOnline = BehaviorRelay<Bool>(value: false)
    let saved = BehaviorRelay<Bool>(value: false)
    
    let followed = BehaviorRelay<Bool>(value: false)
    
    
    let save = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    let userDetail = PublishSubject<Void>()
    let reaction = PublishSubject<UIView>()
    let images = BehaviorRelay<[Observable<URL?>]>(value:[])
        
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
        case .theme:
            return .theme(viewModel: self)
        case .user:
            return .user(viewModel: self)
        }
    }
    
    
    required init(item : Home) {
        self.item = item
                
        userName.accept(item.user?.displayName)
        userHeadImageURL.accept(item.user?.userImage?.url)
        imageURL.accept(item.image?.url)
        title.accept(item.title)
        userOnline.accept(item.user?.loginStatus ?? false)
        recommended.accept(item.recommended)
        saved.accept(item.saved)
        reactionImage.accept(item.reaction?.image)
        images.accept(item.images.map { Observable.just($0.url)})
        followed.accept(item.user?.isFollow ?? false)
        displayName.accept(item.user?.displayName)
    }
}
