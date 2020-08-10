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

//CollectionCellImageHeightCalculateable
class PostsDetailCellViewModel : CellViewModelProtocol , CollectionCellImageHeightCalculateable  {
    
    let item : PostsDetailProduct
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let saved = BehaviorRelay<Bool>(value: false)
    
    let save = PublishSubject<Void>()
    
    var image: String? {
        return item.image
    }
  
    var column : CGFloat = 0
    
    var col: Int {
        return column.int
    }
        
    
    required init(item : PostsDetailProduct) {
        self.item = item
        
        imageURL.accept(item.image?.url)
        title.accept(item.title)
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
    

    let price = BehaviorRelay<String?>(value: nil)

    
    let save = PublishSubject<Void>()
    let like = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()    
    
    
    required init(item : PostsDetail) {
        self.item = item
        
        userImageURL.accept(item.userImage?.url)
        userName.accept(item.displayName)
        postImageURL.accept(item.postImage?.url)
        postTitle.accept(item.title)
        price.accept("$ \(item.price)")
        
        saved.accept(item.saved)
        liked.accept(item.liked)
        recommended.accept(item.recommended)
        
    }
}

