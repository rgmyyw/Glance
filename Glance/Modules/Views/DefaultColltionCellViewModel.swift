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



enum DefaultColltionMemu : Int  {
    case like = 0
    case share = 1
    case delete = 2
    case report = 3
    
    static var own : [DefaultColltionMemu] = [.like,.share,.delete]
    static var other : [DefaultColltionMemu] = [.like,.share,.report]
}

class DefaultColltionCellViewModel : CellViewModelProtocol ,CollectionCellImageHeightCalculateable {
        
    
    let item : DefaultColltionItem
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
    let images = BehaviorRelay<[Observable<URL?>]>(value:[])
    let followed = BehaviorRelay<Bool>(value: false)
    let memu = BehaviorRelay<[DefaultColltionMemu]>(value : [])
    let memuHidden = BehaviorRelay<Bool>(value: true)
    let liked = BehaviorRelay<Bool>(value: false)
    let selected = BehaviorRelay<Bool>(value: false)
    
    
    let more = PublishSubject<Void>()
    let save = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    let userDetail = PublishSubject<Void>()
    let reaction = PublishSubject<UIView>()
    let follow = PublishSubject<Void>()
    
    let like = PublishSubject<Void>()
    let share = PublishSubject<Void>()
    let delete = PublishSubject<Void>()
    let report = PublishSubject<Void>()
    
    
    let recommendButtonHidden = BehaviorRelay<Bool>(value: false)
        
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
    
    
    required init(item : DefaultColltionItem) {
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
        memu.accept(item.own ? DefaultColltionMemu.own : DefaultColltionMemu.other)
    }
}
