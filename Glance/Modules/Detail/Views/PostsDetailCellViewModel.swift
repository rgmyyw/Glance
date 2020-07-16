//
//  PostsDetailCellViewModel.swift
//  Glance
//
//  Created by yanghai on 2020/7/16.
//  Copyright © 2020 yanghai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PostsDetailCellViewModel : CellViewModelProtocol {
    
    let item : PostsDetailProduct
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let saved = BehaviorRelay<Bool>(value: false)
    
    
    
    
    required init(item : PostsDetailProduct) {
        self.item = item
        
        let url = "https://n.sinaimg.cn/spider2020713/360/w760h400/20200713/3d8c-iwhseit9157724.png"
        title.accept(item.title)
        imageURL.accept(url.url)
        saved.accept(item.saved)
    }
}

class PostsDetailSectionCellViewModel : CellViewModelProtocol {
    
    let item : PostsDetail
    let userImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let userName : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let time : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    let postImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let postTitle : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    let saved = BehaviorRelay<Bool>(value: false)
    let liked = BehaviorRelay<Bool>(value: false)
    let recommended = BehaviorRelay<Bool>(value: false)
    
    let height = BehaviorRelay<CGFloat>(value: 400)
    
    
    let save = PublishSubject<Void>()
    let like = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    
    
    required init(item : PostsDetail) {
        self.item = item
        userImageURL.accept(item.userImage?.url)
        userName.accept(item.displayName)
        postImageURL.accept(item.postImage?.url)
        postTitle.accept(item.title)
        
        saved.accept(item.saved)
        liked.accept(item.liked)
        recommended.accept(item.recommended)
        
    }
}

