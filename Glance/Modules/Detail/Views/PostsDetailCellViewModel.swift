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
    
        
    
    let item : DefaultColltionItem
    let imageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let title : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    let saved = BehaviorRelay<Bool>(value: false)
    
    let save = PublishSubject<Void>()
    
    var image: String? {
        return item.image
    }
  
    var col : Int = 2
    var column : Int {
        return col
    }
    
        
    
    required init(item : DefaultColltionItem) {
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
    
    let price = BehaviorRelay<String?>(value: nil)
    let storeName = BehaviorRelay<String?>(value: nil)
    let postImageURL : BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    let postTitle : BehaviorRelay<String?> = BehaviorRelay(value: nil)
    
    let saved = BehaviorRelay<Bool>(value: false)
    let liked = BehaviorRelay<Bool>(value: false)
    let recommended = BehaviorRelay<Bool>(value: false)
    let recommendedButtonHidden = BehaviorRelay<Bool>(value: false)
    let folded : BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    
    let save = PublishSubject<Void>()
    let like = PublishSubject<Void>()
    let recommend = PublishSubject<Void>()
    let viSearch = PublishSubject<UIImage?>()
    let selectStore = PublishSubject<Void>()
    let reloadTitleSection = PublishSubject<Void>()
    
    var bannerHeight : CGFloat {
        if let size = postImageURL.value?.absoluteString.urlImageSize() , size != .zero {
            return size.height / (size.width / UIScreen.width)
        } else {
            return UIScreen.width
        }
    }
    
    var titleFoldedHeight : CGFloat = 5
    var titleExpendHeight : CGFloat = 5
    
    var titleLine : Int {
        return postTitle.value?.line(by: UIFont.titleFont(14), maxWidth: UIScreen.width - 20 * 2) ?? 1
    }
    
    
    required init(item : PostsDetail) {
        self.item = item
        
        
        
        userImageURL.accept(item.userImage?.url)
        userName.accept(item.displayName)
        
        if let image = item.postImage?.url {
            postImageURL.accept(image)
        }
        if let image = item.image?.url {
            postImageURL.accept(image)
        }
        
        postTitle.accept(item.description?.trimmingCharacters(in: .whitespaces) ?? "")
        price.accept(item.price)
        storeName.accept(item.providerName)
        saved.accept(item.saved)
        liked.accept(item.liked)
        recommended.accept(item.recommended)
        recommendedButtonHidden.accept(item.own)
    }
}

